#!/usr/bin/env python3
"""Build the final NCBI-oriented huemul assembly from RagTag outputs.

The script renames the 36 chromosome objects and reference-associated
scaffolds, splits the RagTag Chr0 object into its original components, and
writes the final FASTA, AGP, and identifier mapping tables.
"""

import argparse
import re
from pathlib import Path


def arguments():
    parser = argparse.ArgumentParser()
    parser.add_argument("--agp", required=True, type=Path,
                        help="RagTag scaffold AGP file")
    parser.add_argument("--fasta", required=True, type=Path,
                        help="RagTag scaffold FASTA file")
    parser.add_argument("--output-dir", required=True, type=Path)
    return parser.parse_args()


def read_agp(path):
    objects, order = {}, []
    with path.open() as handle:
        for line in handle:
            if line.startswith("#") or not line.strip():
                continue
            fields = line.rstrip("\n").split("\t")
            if len(fields) < 9:
                raise ValueError(f"Invalid AGP row: {line.rstrip()}")
            obj = fields[0]
            if obj not in objects:
                objects[obj] = []
                order.append(obj)
            objects[obj].append(fields)
    return objects, order


def object_length(rows):
    return max(int(row[2]) for row in rows)


def classify_objects(objects, order):
    chromosome_map = {}
    scaffold_objects = []
    chr0_objects = []

    for obj in order:
        if obj.startswith("NC_"):
            match = re.match(r"NC_0(\d+)\.1(?:_RagTag)?$", obj)
            if not match:
                raise ValueError(f"Unexpected chromosome identifier: {obj}")
            # RagTag scaffolds inherit the O. virginianus (Ovbor_1.2) chromosome
            # accessions. Its 36 chromosomes are numbered by NCBI as NC_069674.1
            # (chr1) through NC_069709.1 (chrY). Subtracting 69673 converts the
            # accession number into the chromosome index (1-36): 1-34 = autosomes,
            # 35 = X, 36 = Y. This constant is specific to this reference version.
            number = int(match.group(1)) - 69673
            if 1 <= number <= 34:
                new_name = f"Hbis_chr{number:02d}"
            elif number == 35:
                new_name = "Hbis_chrX"
            elif number == 36:
                new_name = "Hbis_chrY"
            else:
                raise ValueError(f"Unexpected chromosome accession: {obj}")
            chromosome_map[obj] = new_name
        elif obj.startswith("NW_"):
            scaffold_objects.append((obj, object_length(objects[obj])))
        elif obj.startswith("Chr0"):
            chr0_objects.append(obj)
        else:
            raise ValueError(f"Unrecognized RagTag object: {obj}")

    if len(chr0_objects) != 1:
        raise ValueError(f"Expected exactly one Chr0 object; found {len(chr0_objects)}")

    scaffold_objects.sort(key=lambda item: (-item[1], item[0]))
    scaffold_map = {
        obj: f"Hbis_scaffold{index:03d}"
        for index, (obj, _) in enumerate(scaffold_objects, start=1)
    }
    return chromosome_map, scaffold_map, chr0_objects[0]


def chr0_components(objects, chr0_obj):
    components = []
    for row in objects[chr0_obj]:
        if row[4] == "W":
            components.append({
                "component": row[5],
                "object_start": int(row[1]),
                "object_end": int(row[2]),
                "component_start": int(row[6]),
                "component_end": int(row[7]),
                "orientation": row[8],
            })

    components.sort(key=lambda item: (
        -(item["object_end"] - item["object_start"] + 1),
        item["component"],
    ))

    seen = set()
    for index, item in enumerate(components, start=1):
        if item["component"] in seen:
            raise ValueError(f"Duplicated Chr0 component: {item['component']}")
        seen.add(item["component"])
        item["new_name"] = f"Hbis_unplaced{index:03d}"
        item["offset"] = item["object_start"] - 1
        item["length"] = item["object_end"] - item["object_start"] + 1
    return components


def read_fasta(path):
    name, sequence = None, []
    with path.open() as handle:
        for line in handle:
            if line.startswith(">"):
                if name is not None:
                    yield name, "".join(sequence)
                name = line[1:].split()[0]
                sequence = []
            else:
                sequence.append(line.strip())
    if name is not None:
        yield name, "".join(sequence)


def reverse_complement(sequence):
    translation = str.maketrans("ACGTacgtNn", "TGCAtgcaNn")
    return sequence.translate(translation)[::-1]


def write_fasta_record(handle, name, sequence, width=60):
    handle.write(f">{name}\n")
    for start in range(0, len(sequence), width):
        handle.write(sequence[start:start + width] + "\n")


def write_outputs(args, objects, order, chromosome_map, scaffold_map,
                  chr0_obj, components):
    args.output_dir.mkdir(parents=True, exist_ok=True)
    output_fasta = args.output_dir / "Hbis_scaffolds_NCBI.fasta"
    output_agp = args.output_dir / "Hbis_assembly.agp"
    mapped_fasta_objects = set()

    with output_fasta.open("w") as output:
        for name, sequence in read_fasta(args.fasta):
            if name in chromosome_map:
                write_fasta_record(output, chromosome_map[name], sequence)
                mapped_fasta_objects.add(name)
            elif name in scaffold_map:
                write_fasta_record(output, scaffold_map[name], sequence)
                mapped_fasta_objects.add(name)
            elif name == chr0_obj:
                for item in components:
                    subsequence = sequence[item["offset"]:item["offset"] + item["length"]]
                    if len(subsequence) != item["length"]:
                        raise ValueError(f"Invalid Chr0 interval for {item['component']}")
                    if item["orientation"] == "-":
                        subsequence = reverse_complement(subsequence)
                    write_fasta_record(output, item["new_name"], subsequence)
                mapped_fasta_objects.add(name)
            else:
                raise ValueError(f"FASTA object absent from AGP mapping: {name}")

    expected_objects = set(chromosome_map) | set(scaffold_map) | {chr0_obj}
    missing = expected_objects - mapped_fasta_objects
    if missing:
        raise ValueError(f"AGP objects absent from FASTA: {sorted(missing)}")

    with output_agp.open("w") as output:
        output.write("##agp-version 2.1\n")
        output.write("# Hippocamelus bisulcus reference-guided assembly\n")
        for obj in order:
            new_name = chromosome_map.get(obj, scaffold_map.get(obj))
            if new_name is None:
                continue
            for row in objects[obj]:
                renamed = list(row)
                renamed[0] = new_name
                output.write("\t".join(renamed) + "\n")
        for item in components:
            output.write("\t".join([
                item["new_name"], "1", str(item["length"]), "1", "W",
                item["component"], "1", str(item["length"]), "+",
            ]) + "\n")

    with (args.output_dir / "object_name_map.tsv").open("w") as output:
        output.write("old_ragtag_object\tnew_Hbis_name\ttype\n")
        for old, new in chromosome_map.items():
            output.write(f"{old}\t{new}\tchromosome\n")
        for old, new in scaffold_map.items():
            output.write(f"{old}\t{new}\tunlocalized_scaffold\n")

    with (args.output_dir / "chr0_split_map.tsv").open("w") as output:
        output.write("chr0_contig\tnew_Hbis_name\toffset_0based_in_Chr0\tlength\torientation\n")
        for item in components:
            output.write(
                f"{item['component']}\t{item['new_name']}\t{item['offset']}\t"
                f"{item['length']}\t{item['orientation']}\n"
            )

    return output_fasta, output_agp


def main():
    args = arguments()
    objects, order = read_agp(args.agp)
    chromosome_map, scaffold_map, chr0_obj = classify_objects(objects, order)
    components = chr0_components(objects, chr0_obj)
    output_fasta, output_agp = write_outputs(
        args, objects, order, chromosome_map, scaffold_map, chr0_obj, components
    )

    total = len(chromosome_map) + len(scaffold_map) + len(components)
    print(f"Chromosomes: {len(chromosome_map)}")
    print(f"Reference-associated scaffolds: {len(scaffold_map)}")
    print(f"Unplaced Chr0 components: {len(components)}")
    print(f"Total output sequences: {total}")
    print(f"FASTA: {output_fasta}")
    print(f"AGP: {output_agp}")


if __name__ == "__main__":
    main()

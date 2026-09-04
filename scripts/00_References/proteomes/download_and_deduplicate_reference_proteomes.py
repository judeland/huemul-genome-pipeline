#!/usr/bin/env python3
"""Download and standardize annotated Cervidae reference proteomes.

The script automatically surveys annotated Cervidae assemblies available from
NCBI and retains one assembly per taxon, prioritizing RefSeq over GenBank,
chromosome-level assemblies, and higher protein-coding gene counts.

Because NCBI holdings may change, the exact accessions selected for the
analysis are also downloaded, processed, and copied into ``orthofinder``. The
representative target-species proteome produced by the annotation pipeline must
be added separately.

Outputs:
    all_available/  Downloaded protein FASTA and genomic GFF files.
    deduplicated/   Longest protein isoform per gene for every reference.
    orthofinder/    Exact reference proteomes selected for OrthoFinder.
    manifests/      Download, deduplication, and selection records.

Requirements: requests, biopython
"""

import argparse
import csv
import io
import re
import shutil
import time
import zipfile
from collections import defaultdict
from pathlib import Path

import requests
from Bio import SeqIO


BASE_URL = "https://api.ncbi.nlm.nih.gov/datasets/v2"
LEVEL_RANK = {"Complete Genome": 0, "Chromosome": 1, "Scaffold": 2, "Contig": 3}

# Exact reference proteomes selected for the OrthoFinder analysis. All other
# annotated Cervidae proteomes discovered by the survey are processed as well.
ORTHOFINDER_REFERENCES = [
    ("Cervus canadensis", "Cervus_canadensis", "GCF_019320065.1"),
    ("Cervus elaphus", "Cervus_elaphus", "GCF_910594005.1"),
    ("Cervus hanglu yarkandensis", "Cervus_hanglu_yarkandensis", "GCA_010411085.1"),
    ("Dama dama", "Dama_dama", "GCF_033118175.1"),
    ("Muntiacus muntjak", "Muntiacus_muntjak", "GCA_008782695.1"),
    ("Muntiacus reevesi", "Muntiacus_reevesi", "GCF_963930625.1"),
    ("Odocoileus virginianus", "Odocoileus_virginianus", "GCF_023699985.2"),
    ("Rangifer tarandus", "Rangifer_tarandus", "GCA_949782905.1"),
    ("Bos taurus", "Bos_taurus", "GCF_002263795.3"),
]


def arguments():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--output-directory",
        type=Path,
        default=Path("references/proteomic"),
        help="Output directory. Default: references/proteomic",
    )
    parser.add_argument("--overwrite", action="store_true")
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="List references without downloading files",
    )
    parser.add_argument("--request-delay", type=float, default=1.2)
    return parser.parse_args()


def safe_name(species):
    return re.sub(r"[^A-Za-z0-9_]", "_", "_".join(species.split()[:3]))


def discover_annotated_cervidae():
    """Return one annotated assembly per available Cervidae taxon."""
    url = f"{BASE_URL}/genome/taxon/Cervidae/dataset_report"
    params = {"filters.has_annotation": True, "page_size": 200}
    reports = []
    page_token = None

    while True:
        if page_token:
            params["page_token"] = page_token
        response = requests.get(url, params=params, timeout=300)
        response.raise_for_status()
        data = response.json()
        reports.extend(data.get("reports", []))
        page_token = data.get("next_page_token")
        if not page_token:
            break
        time.sleep(0.3)

    candidates = []
    for report in reports:
        species = report.get("organism", {}).get("organism_name", "")
        accession = report.get("accession", "")
        if not species or not accession:
            continue
        level = report.get("assembly_info", {}).get("assembly_level", "")
        protein_count = (
            report.get("annotation_info", {})
            .get("stats", {})
            .get("gene_counts", {})
            .get("protein_coding", 0)
        )
        candidates.append({
            "species": species,
            "file_name": safe_name(species),
            "taxon": " ".join(species.split()[:2]),
            "accession": accession,
            "assembly_level": level,
            "protein_coding": protein_count,
            "refseq_rank": 0 if accession.startswith("GCF_") else 1,
            "level_rank": LEVEL_RANK.get(level, 9),
            "selected_for_orthofinder": "no",
        })

    candidates.sort(key=lambda row: (
        row["taxon"], row["refseq_rank"], row["level_rank"],
        -row["protein_coding"], row["accession"],
    ))
    selected = {}
    for row in candidates:
        selected.setdefault(row["taxon"], row)
    return list(selected.values())


def download_member(accession, annotation_type, suffixes, output_path,
                    overwrite=False, attempts=4):
    if output_path.exists() and not overwrite:
        return output_path
    if isinstance(suffixes, str):
        suffixes = (suffixes,)
    url = f"{BASE_URL}/genome/accession/{accession}/download"
    params = {
        "include_annotation_type": annotation_type,
        "hydrated": "FULLY_HYDRATED",
    }

    for attempt in range(1, attempts + 1):
        try:
            response = requests.get(url, params=params, stream=True, timeout=300)
            response.raise_for_status()
            content = b"".join(response.iter_content(8192))
            with zipfile.ZipFile(io.BytesIO(content)) as archive:
                members = [name for name in archive.namelist() if name.endswith(suffixes)]
                if not members:
                    raise RuntimeError(f"No {suffixes} file returned for {accession}")
                member = max(members, key=lambda name: archive.getinfo(name).file_size)
                output_path.write_bytes(archive.read(member))
            return output_path
        except (requests.RequestException, zipfile.BadZipFile, RuntimeError) as error:
            if attempt == attempts:
                raise
            wait_seconds = attempt * 5
            print(f"Download interrupted ({error}); retrying in {wait_seconds} seconds")
            time.sleep(wait_seconds)
    return output_path


def attribute(attributes, key):
    match = re.search(rf"(?:^|;){re.escape(key)}=([^;]+)", attributes)
    return match.group(1).strip() if match else None


def parse_gff(gff_path):
    transcript_to_gene = {}
    cds_lengths = defaultdict(int)
    protein_to_transcript = {}

    with gff_path.open(encoding="utf-8", errors="replace") as handle:
        for line in handle:
            if line.startswith("#"):
                continue
            fields = line.rstrip("\n").split("\t")
            if len(fields) < 9:
                continue
            feature, attributes = fields[2], fields[8]
            if feature in {"mRNA", "transcript"}:
                transcript_id = attribute(attributes, "ID")
                gene_id = (
                    attribute(attributes, "Parent")
                    or attribute(attributes, "gene_id")
                    or transcript_id
                )
                if transcript_id:
                    transcript_to_gene[transcript_id] = gene_id
            elif feature == "CDS":
                parents = attribute(attributes, "Parent")
                protein_id = attribute(attributes, "protein_id")
                parent_ids = [value.strip() for value in parents.split(",")] if parents else []
                length = int(fields[4]) - int(fields[3]) + 1
                for parent_id in parent_ids:
                    cds_lengths[parent_id] += length
                    if protein_id:
                        protein_to_transcript[protein_id] = parent_id

    longest_by_gene = {}
    longest_length = {}
    for transcript_id, gene_id in transcript_to_gene.items():
        length = cds_lengths.get(transcript_id, 0)
        if gene_id not in longest_length or length > longest_length[gene_id]:
            longest_by_gene[gene_id] = transcript_id
            longest_length[gene_id] = length
    return set(longest_by_gene.values()), protein_to_transcript


def representative_proteome(protein_fasta, genomic_gff, output_fasta):
    longest_transcripts, protein_to_transcript = parse_gff(genomic_gff)
    total = 0
    retained = []
    for record in SeqIO.parse(str(protein_fasta), "fasta"):
        total += 1
        transcript_id = protein_to_transcript.get(record.id)
        keep = record.id in longest_transcripts or transcript_id in longest_transcripts
        if not keep:
            match = re.search(r"protein_id=([^\];\s]+)", record.description)
            keep = bool(
                match
                and protein_to_transcript.get(match.group(1)) in longest_transcripts
            )
        if keep:
            retained.append(record)
    SeqIO.write(retained, str(output_fasta), "fasta")
    return total, len(retained), len(longest_transcripts)


def write_manifest(rows, output_path):
    if not rows:
        return
    with output_path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=rows[0].keys(), delimiter="\t")
        writer.writeheader()
        writer.writerows(rows)


def main():
    args = arguments()
    all_dir = args.output_directory / "all_available"
    deduplicated_dir = args.output_directory / "deduplicated"
    orthofinder_dir = args.output_directory / "orthofinder"
    manifests_dir = args.output_directory / "manifests"
    for directory in (all_dir, deduplicated_dir, orthofinder_dir, manifests_dir):
        directory.mkdir(parents=True, exist_ok=True)

    references = {row["accession"]: row for row in discover_annotated_cervidae()}
    for species, file_name, accession in ORTHOFINDER_REFERENCES:
        entry = references.setdefault(accession, {
            "species": species,
            "file_name": file_name,
            "taxon": " ".join(species.split()[:2]),
            "accession": accession,
            "assembly_level": "selected reference",
            "protein_coding": "",
            "refseq_rank": 0 if accession.startswith("GCF_") else 1,
            "level_rank": 9,
        })
        entry["selected_for_orthofinder"] = "yes"
        entry["file_name"] = file_name

    if args.dry_run:
        print("species\taccession\tassembly_level\tselected_for_orthofinder")
        for accession, entry in sorted(references.items(), key=lambda item: item[1]["file_name"]):
            print(
                f"{entry['species']}\t{accession}\t{entry['assembly_level']}\t"
                f"{entry.get('selected_for_orthofinder', 'no')}"
            )
        print(f"\nTotal references: {len(references)}")
        return

    downloads = []
    deduplications = []
    representative_files = {}
    for accession, entry in sorted(references.items(), key=lambda item: item[1]["file_name"]):
        accession_name = accession.replace(".", "_")
        reference_dir = all_dir / f"{entry['file_name']}__{accession_name}"
        reference_dir.mkdir(parents=True, exist_ok=True)
        protein_fasta = reference_dir / f"{entry['file_name']}.faa"
        genomic_gff = reference_dir / f"{entry['file_name']}.gff3"

        print(f"Downloading {entry['species']} ({accession})")
        download_member(accession, "PROT_FASTA", "protein.faa", protein_fasta, args.overwrite)
        time.sleep(args.request_delay)
        download_member(accession, "GENOME_GFF", (".gff", ".gff3"), genomic_gff, args.overwrite)
        time.sleep(args.request_delay)

        protein_count = sum(1 for _ in SeqIO.parse(str(protein_fasta), "fasta"))
        representative_fasta = deduplicated_dir / f"{entry['file_name']}__{accession_name}.faa"
        total, retained, selected_transcripts = representative_proteome(
            protein_fasta, genomic_gff, representative_fasta
        )
        representative_files[accession] = representative_fasta
        print(f"  Proteins: {total:,} -> {retained:,}")

        downloads.append({
            "species": entry["species"],
            "accession": accession,
            "assembly_level": entry["assembly_level"],
            "downloaded_proteins": protein_count,
            "selected_for_orthofinder": entry.get("selected_for_orthofinder", "no"),
            "protein_fasta": str(protein_fasta),
            "genomic_gff": str(genomic_gff),
        })
        deduplications.append({
            "species": entry["species"],
            "accession": accession,
            "original_proteins": total,
            "representative_proteins": retained,
            "selected_transcripts": selected_transcripts,
            "representative_fasta": str(representative_fasta),
        })

    orthofinder_manifest = []
    for species, file_name, accession in ORTHOFINDER_REFERENCES:
        destination = orthofinder_dir / f"{file_name}.faa"
        shutil.copy2(representative_files[accession], destination)
        orthofinder_manifest.append({
            "species": species,
            "accession": accession,
            "proteome": destination.name,
        })

    write_manifest(downloads, manifests_dir / "downloaded_proteomes.tsv")
    write_manifest(deduplications, manifests_dir / "deduplicated_proteomes.tsv")
    write_manifest(orthofinder_manifest, manifests_dir / "orthofinder_references.tsv")

    print(f"\nDownloaded proteomes: {all_dir}")
    print(f"Deduplicated proteomes: {deduplicated_dir}")
    print(f"OrthoFinder references: {orthofinder_dir}")
    print(f"Manifests: {manifests_dir}")
    print("Add the representative target-species proteome to the orthofinder directory.")


if __name__ == "__main__":
    main()

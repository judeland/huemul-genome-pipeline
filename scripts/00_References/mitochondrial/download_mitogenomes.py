#!/usr/bin/env python3
"""Download reference mitogenomes and prepare the phylogenetic dataset.

The dataset contains one mitochondrial representative per selected cervid
genus from NCBI Nucleotide RefSeq, four annotated mitochondrial replicons from
chromosome-level genome assemblies, the locally assembled target-species
mitochondrial genome, and Bos taurus as the outgroup.

Requirements: biopython
"""

import time
from pathlib import Path

from Bio import Entrez, SeqIO
from Bio.SeqRecord import SeqRecord


# NCBI requires a valid contact email for Entrez requests. Replace the address
# below with your own before running; NCBI may throttle or block requests that
# use a placeholder. An API key is optional (raises the rate limit); leave it
# as None if you do not have one.
Entrez.email = "your.email@institution.org"  # <-- replace with a real email
Entrez.api_key = None

REFERENCE_DIR = Path("references/mitochondrial")
INDIVIDUAL_DIR = REFERENCE_DIR / "individual"
OUTPUT_DIR = Path("mitochondrial_phylogeny/input")
TARGET_MITOGENOME = Path(
    "mitochondrial_assembly/Hbis_complete_mitochondrial_genome.fasta"
)
OUTPUT_FASTA = OUTPUT_DIR / "mitochondrial_genomes.fasta"
OUTPUT_MANIFEST = OUTPUT_DIR / "mitochondrial_genomes.tsv"


# Complete mitochondrial genomes selected from NCBI Nucleotide RefSeq.
REFSEQ_MITOGENOMES = {
    "Hippocamelus_antisensis": "NC_020711.1",
    "Ozotoceros_bezoarticus": "NC_020766.1",
    "Blastocerus_dichotomus": "NC_020682.1",
    "Pudu_puda": "NC_020740.1",
    "Mazama_americana": "NC_020719.1",
    "Odocoileus_virginianus": "NC_015247.1",
    "Rangifer_tarandus": "NC_007703.1",
    "Alces_alces": "NC_020677.1",
    "Capreolus_capreolus": "NC_020684.1",
    "Muntiacus_muntjak": "NC_004563.1",
}


# Annotated mitochondrial replicons retrieved from chromosome-level genome
# assemblies used in the comparative genomic analysis.
ASSEMBLY_MITOCHONDRIAL_REPLICONS = {
    "Cervus_canadensis": "CM033226.1",
    "Cervus_elaphus": "OU343111.2",
    "Dama_dama": "CM065635.2",
    "Muntiacus_reevesi": "OZ005647.2",
}


OUTGROUP = {
    "Bos_taurus": "NC_006853.1",
}


def fetch_sequence(species_name, accession):
    handle = Entrez.efetch(
        db="nucleotide",
        id=accession,
        rettype="fasta",
        retmode="text",
    )
    record = SeqIO.read(handle, "fasta")
    handle.close()
    return SeqRecord(
        record.seq,
        id=f"{species_name}|{accession}",
        description="",
    )


OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
INDIVIDUAL_DIR.mkdir(parents=True, exist_ok=True)
records = []
manifest = []


for source_name, accessions in (
    ("NCBI_Nucleotide_RefSeq", REFSEQ_MITOGENOMES),
    ("genome_assembly_replicon", ASSEMBLY_MITOCHONDRIAL_REPLICONS),
    ("outgroup", OUTGROUP),
):
    for species_name, accession in accessions.items():
        print(f"Downloading {species_name} ({accession})")
        record = fetch_sequence(species_name, accession)
        SeqIO.write(
            record,
            INDIVIDUAL_DIR / f"{species_name}_{accession}.fasta",
            "fasta",
        )
        records.append(record)
        manifest.append({
            "species": species_name,
            "accession": accession,
            "source": source_name,
            "length_bp": len(record.seq),
        })
        time.sleep(0.4)


# The normalized target mitogenome is added to the multifasta.
target_record = SeqIO.read(TARGET_MITOGENOME, "fasta")
target_record = SeqRecord(
    target_record.seq,
    id="Hippocamelus_bisulcus|assembled_mitogenome",
    description="",
)
records.insert(0, target_record)
manifest.insert(0, {
    "species": "Hippocamelus_bisulcus",
    "accession": "assembled_mitogenome",
    "source": "local_assembly",
    "length_bp": len(target_record.seq),
})


SeqIO.write(records, OUTPUT_FASTA, "fasta")

with OUTPUT_MANIFEST.open("w", encoding="utf-8") as handle:
    handle.write("species\taccession\tsource\tlength_bp\n")
    for row in manifest:
        handle.write(
            f"{row['species']}\t{row['accession']}\t"
            f"{row['source']}\t{row['length_bp']}\n"
        )


print()
print(f"Multifasta written to: {OUTPUT_FASTA}")
print(f"Manifest written to: {OUTPUT_MANIFEST}")
print(f"Total sequences: {len(records)}")

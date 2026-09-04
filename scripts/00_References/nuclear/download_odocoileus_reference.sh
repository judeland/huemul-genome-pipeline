#!/usr/bin/env bash
set -euo pipefail

# Downloads the Odocoileus virginianus genomic reference used for
# RagTag, LiftOn, and reference-based assembly QC.
#
# Requirements: wget and gzip.
# Output note: existing files with the same names are overwritten.

OUTPUT_DIR="references/genomic"
BASE_URL="https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/023/699/985/GCF_023699985.2_Ovbor_1.2"

mkdir -p "$OUTPUT_DIR"

wget \
    "$BASE_URL/GCF_023699985.2_Ovbor_1.2_genomic.fna.gz" \
    -O "$OUTPUT_DIR/GCF_023699985.2_Ovbor_1.2_genomic.fna.gz"

wget \
    "$BASE_URL/GCF_023699985.2_Ovbor_1.2_genomic.gff.gz" \
    -O "$OUTPUT_DIR/GCF_023699985.2_Ovbor_1.2_genomic.gff.gz"

wget \
    "$BASE_URL/GCF_023699985.2_Ovbor_1.2_assembly_report.txt" \
    -O "$OUTPUT_DIR/GCF_023699985.2_Ovbor_1.2_assembly_report.txt"

gunzip -f "$OUTPUT_DIR/GCF_023699985.2_Ovbor_1.2_genomic.fna.gz"
gunzip -f "$OUTPUT_DIR/GCF_023699985.2_Ovbor_1.2_genomic.gff.gz"

echo "Genomic reference: $OUTPUT_DIR/GCF_023699985.2_Ovbor_1.2_genomic.fna"
echo "Genomic annotation: $OUTPUT_DIR/GCF_023699985.2_Ovbor_1.2_genomic.gff"
echo "Assembly report: $OUTPUT_DIR/GCF_023699985.2_Ovbor_1.2_assembly_report.txt"

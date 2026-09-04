#!/usr/bin/env bash
set -euo pipefail

# Reproduces the final LiftOn annotation transfer performed on the NCBI-ready
# H. bisulcus assembly. The O. virginianus reference FASTA and GFF3 supplied
# to this script must be nuclear-only (mitochondrial record NC_015247.1
# excluded). Additional copies are retained with -copies, and the minimum
# sequence-coverage threshold is 0.95.
#
# Requirements: LiftOn, the final H. bisulcus assembly, and the nuclear-only
# O. virginianus reference FASTA and GFF3.
# Output note: change OUTPUT_DIR before rerunning to preserve previous results.

TARGET_ASSEMBLY="NCBI_submission/Hbis_scaffolds_NCBI.fasta"
REFERENCE_FASTA="references/genomic/nuclear/Ovbor_1.2_nuclear.fna"
REFERENCE_GFF="references/genomic/nuclear/Ovbor_1.2_nuclear.gff3"
OUTPUT_DIR="lifton_output"
THREADS=16  # Edit according to the available CPU resources

mkdir -p "$OUTPUT_DIR"

lifton \
    -g "$REFERENCE_GFF" \
    -o "$OUTPUT_DIR/Hbis_nuclear_annotation_LiftOn.gff3" \
    -copies \
    -sc 0.95 \
    -t "$THREADS" \
    "$TARGET_ASSEMBLY" \
    "$REFERENCE_FASTA" \
    2>&1 | tee "$OUTPUT_DIR/lifton.log"

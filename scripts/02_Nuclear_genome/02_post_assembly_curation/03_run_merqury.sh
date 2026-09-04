#!/usr/bin/env bash
set -euo pipefail

# Builds the 21-mer database used in the study and evaluates the raw Flye and
# post-Medaka assemblies independently with Merqury. Both assemblies are
# compared against the same database generated from the combined reads.
#
# Requirements: Meryl 1.4.1, Merqury 1.3, the combined ONT reads, the Flye
# draft assembly, and the Medaka-polished assembly.
# Run this script from the repository root.
# Output note: files with the same names in OUTPUT_DIR are overwritten.

READS="QC_reads/shehuen_coiron_reads.fastq.gz"
FLYE_ASSEMBLY="Flye_assembly/assembly.fasta"
POLISHED_ASSEMBLY="Medaka/assembly_polished.fasta"
OUTPUT_DIR="Merqury"
THREADS=16  # Edit according to the available CPU resources

mkdir -p "$OUTPUT_DIR/meryl_db" "$OUTPUT_DIR/qc/merqury"

meryl \
    k=21 \
    count \
    threads="$THREADS" \
    "$READS" \
    output "$OUTPUT_DIR/meryl_db/combined_reads.meryl"

READS_MERYL_DATABASE="$OUTPUT_DIR/meryl_db/combined_reads.meryl" \
ASSEMBLY_FASTA="$FLYE_ASSEMBLY" \
MERQURY_OUTPUT_PREFIX="$OUTPUT_DIR/qc/merqury/flye_raw" \
bash scripts/07_Shared_QC/merqury.sh

READS_MERYL_DATABASE="$OUTPUT_DIR/meryl_db/combined_reads.meryl" \
ASSEMBLY_FASTA="$POLISHED_ASSEMBLY" \
MERQURY_OUTPUT_PREFIX="$OUTPUT_DIR/qc/merqury/post_medaka" \
bash scripts/07_Shared_QC/merqury.sh

echo "Merqury results: $OUTPUT_DIR/qc/merqury"

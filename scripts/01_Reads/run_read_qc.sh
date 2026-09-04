#!/usr/bin/env bash
set -euo pipefail

# Summarizes the quality-filtered Oxford Nanopore reads from each individual,
# concatenates both datasets, and generates a combined NanoPlot report.
#
# Requirements: NanoStat, NanoPlot, and the two quality-filtered FASTQ files.
# Run this script from the repository root.
# Output note: files with the same names in OUTPUT_DIR are overwritten.

SHEHUEN_READS="reads/Shehuen.fastq.gz"
COIRON_READS="reads/Coiron.fastq.gz"
OUTPUT_DIR="QC_reads"

mkdir -p "$OUTPUT_DIR"

COMBINED_READS="$OUTPUT_DIR/shehuen_coiron_reads.fastq.gz"

# Per-individual read statistics.
READS_FASTQ="$SHEHUEN_READS" \
NANOSTAT_OUTPUT="$OUTPUT_DIR/qc/nanostat/NanoStat_Shehuen.txt" \
bash scripts/07_Shared_QC/nanostat.sh

READS_FASTQ="$COIRON_READS" \
NANOSTAT_OUTPUT="$OUTPUT_DIR/qc/nanostat/NanoStat_Coiron.txt" \
bash scripts/07_Shared_QC/nanostat.sh

# Concatenation of the two gzip-compressed FASTQ datasets.
cat "$SHEHUEN_READS" "$COIRON_READS" > "$COMBINED_READS"

# Combined-read graphical report.
READS_FASTQ="$COMBINED_READS" \
NANOPLOT_OUTPUT_DIR="$OUTPUT_DIR/qc/nanoplot" \
bash scripts/07_Shared_QC/nanoplot.sh

echo "Combined reads: $COMBINED_READS"

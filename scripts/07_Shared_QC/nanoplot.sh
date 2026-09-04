#!/usr/bin/env bash
set -euo pipefail

# Generates graphical quality summaries for Oxford Nanopore reads.
# Requirements: NanoPlot and a FASTQ file supplied by the calling reads-QC
# stage. Multiple read sets may be concatenated before calling this script.
# Inputs from calling stage: READS_FASTQ and NANOPLOT_OUTPUT_DIR.

THREADS=16  # Edit according to the available CPU resources

mkdir -p "$NANOPLOT_OUTPUT_DIR"

NanoPlot \
    --fastq "$READS_FASTQ" \
    --threads "$THREADS" \
    --outdir "$NANOPLOT_OUTPUT_DIR"

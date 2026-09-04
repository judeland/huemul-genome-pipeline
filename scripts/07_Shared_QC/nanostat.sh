#!/usr/bin/env bash
set -euo pipefail

# Generates tabular quality statistics for Oxford Nanopore reads.
# Requirements: NanoStat and a FASTQ file supplied by the calling reads-QC
# stage.
# Inputs from calling stage: READS_FASTQ and NANOSTAT_OUTPUT.

mkdir -p "$(dirname "$NANOSTAT_OUTPUT")"
NanoStat --fastq "$READS_FASTQ" > "$NANOSTAT_OUTPUT"

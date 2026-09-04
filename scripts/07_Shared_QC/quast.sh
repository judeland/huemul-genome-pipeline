#!/usr/bin/env bash
set -euo pipefail

# Evaluates the final H. bisulcus assembly against the nuclear O. virginianus
# reference using QUAST in large, fragmented-reference mode.
# Requirements: QUAST, the final assembly, and the nuclear reference FASTA
# supplied by the final scaffolding/QC stage.
# Inputs from calling stage: ASSEMBLY_FASTA, REFERENCE_FASTA, and
# QUAST_OUTPUT_DIR.

THREADS=16  # Edit according to the available CPU resources

mkdir -p "$QUAST_OUTPUT_DIR"

quast.py \
    "$ASSEMBLY_FASTA" \
    -r "$REFERENCE_FASTA" \
    -o "$QUAST_OUTPUT_DIR" \
    --min-contig 500 \
    --large \
    --fragmented \
    -t "$THREADS" \
    2>&1 | tee "$QUAST_OUTPUT_DIR/quast.log"

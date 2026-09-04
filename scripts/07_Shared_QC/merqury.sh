#!/usr/bin/env bash
set -euo pipefail

# Evaluates reference-free assembly consensus quality and k-mer completeness.
# Requirements: Merqury, Meryl, a Meryl database generated from the filtered
# reads, and an assembly FASTA supplied by the calling pipeline stage.
# Inputs from calling stage: READS_MERYL_DATABASE, ASSEMBLY_FASTA, and
# MERQURY_OUTPUT_PREFIX.

mkdir -p "$(dirname "$MERQURY_OUTPUT_PREFIX")"
merqury.sh "$READS_MERYL_DATABASE" "$ASSEMBLY_FASTA" "$MERQURY_OUTPUT_PREFIX"

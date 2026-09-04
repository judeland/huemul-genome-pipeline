#!/usr/bin/env bash
set -euo pipefail

# Generates basic FASTA assembly statistics with assembly-stats.
# Requirements: assembly-stats and an assembly FASTA supplied by the calling
# pipeline stage.
# Inputs from calling stage: ASSEMBLY_FASTA and ASSEMBLY_STATS_OUTPUT.

mkdir -p "$(dirname "$ASSEMBLY_STATS_OUTPUT")"
assembly-stats "$ASSEMBLY_FASTA" > "$ASSEMBLY_STATS_OUTPUT"

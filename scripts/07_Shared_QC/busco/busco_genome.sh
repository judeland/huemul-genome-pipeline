#!/usr/bin/env bash
set -euo pipefail

# Evaluates assembly completeness with BUSCO 6.1.0 in genome mode against the
# Cetartiodactyla odb10 lineage.
# Requirements: BUSCO 6.1.0, Miniprot, the cetartiodactyla_odb10 dataset, and
# an assembly FASTA supplied by the calling pipeline stage.
# Inputs from calling stage: ASSEMBLY_FASTA, BUSCO_RUN_NAME, BUSCO_OUTPUT_DIR,
# and BUSCO_DOWNLOAD_DIR.
# Warning: -f overwrites an existing BUSCO run with the same run name. Change
# BUSCO_RUN_NAME or BUSCO_OUTPUT_DIR before rerunning to preserve old results.

THREADS=16  # Edit according to the available CPU resources

mkdir -p "$BUSCO_OUTPUT_DIR"

busco \
    -i "$ASSEMBLY_FASTA" \
    -o "$BUSCO_RUN_NAME" \
    --out_path "$BUSCO_OUTPUT_DIR" \
    --download_path "$BUSCO_DOWNLOAD_DIR" \
    -m genome \
    -l cetartiodactyla_odb10 \
    --offline \
    -c "$THREADS" \
    -f \
    2>&1 | tee "$BUSCO_OUTPUT_DIR/${BUSCO_RUN_NAME}.log"

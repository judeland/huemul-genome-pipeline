#!/usr/bin/env bash
set -euo pipefail

# Infers the maximum-likelihood mitochondrial phylogeny from the MAFFT
# alignment of 16 complete mitochondrial genomes.
#
# Historical analysis:
# - IQ-TREE 3.1.2
# - automatic model selection with ModelFinder Plus
# - 1,000 ultrafast bootstrap replicates
# - Bos taurus as the outgroup
# - automatic thread selection
#
# Requirement: IQ-TREE 3.1.2.
#
# Reusing OUTPUT_PREFIX may overwrite existing IQ-TREE results.

ALIGNMENT="mitochondrial_phylogeny/mafft/mitochondrial_genomes_aligned.fasta"

OUTPUT_DIR="mitochondrial_phylogeny/iqtree"
OUTPUT_PREFIX="${OUTPUT_DIR}/mitochondrial_tree_iqtree"

mkdir -p "$OUTPUT_DIR"

iqtree3 \
    -s "$ALIGNMENT" \
    -m MFP \
    -B 1000 \
    -T AUTO \
    -o "Bos_taurus|NC_006853.1" \
    --prefix "$OUTPUT_PREFIX"

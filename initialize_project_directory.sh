#!/usr/bin/env bash
set -euo pipefail

# Creates a self-contained directory for running the documented analyses.
# The first argument is the desired location. If omitted, the directory is
# created as huemul_genome_analysis in the current location.

PROJECT_DIR="${1:-huemul_genome_analysis}"
REPOSITORY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$PROJECT_DIR"

# Copy the scripts and repository documentation into the working directory.
cp -R "$REPOSITORY_DIR/scripts" "$PROJECT_DIR/"
cp "$REPOSITORY_DIR/README.md" "$PROJECT_DIR/"
cp "$REPOSITORY_DIR/SOFTWARE.md" "$PROJECT_DIR/"

# Reads and shared resources.
mkdir -p \
    "$PROJECT_DIR/reads" \
    "$PROJECT_DIR/QC_reads" \
    "$PROJECT_DIR/references/genomic/nuclear" \
    "$PROJECT_DIR/references/proteomic/all_available" \
    "$PROJECT_DIR/references/proteomic/orthofinder" \
    "$PROJECT_DIR/references/mitochondrial/individual" \
    "$PROJECT_DIR/busco_downloads"

# Nuclear-genome analysis directories.
mkdir -p \
    "$PROJECT_DIR/Flye_assembly" \
    "$PROJECT_DIR/Purge_dups" \
    "$PROJECT_DIR/Medaka" \
    "$PROJECT_DIR/Merqury" \
    "$PROJECT_DIR/FCS_GX" \
    "$PROJECT_DIR/Mitochondrial_screen" \
    "$PROJECT_DIR/Length_filter" \
    "$PROJECT_DIR/FCS_adaptor" \
    "$PROJECT_DIR/RagTag" \
    "$PROJECT_DIR/NCBI_submission" \
    "$PROJECT_DIR/repeatmodeler" \
    "$PROJECT_DIR/repeatmasker" \
    "$PROJECT_DIR/lifton_output" \
    "$PROJECT_DIR/agat_output"

# Mitochondrial and comparative-analysis directories.
mkdir -p \
    "$PROJECT_DIR/mitochondrial_assembly/input_reads" \
    "$PROJECT_DIR/mitochondrial_assembly/pmat" \
    "$PROJECT_DIR/mitochondrial_phylogeny/input" \
    "$PROJECT_DIR/mitochondrial_phylogeny/mafft" \
    "$PROJECT_DIR/mitochondrial_phylogeny/iqtree" \
    "$PROJECT_DIR/comparative_genomics/iqtree"

echo "Working directory created at: $PROJECT_DIR"
echo "Run individual scripts from inside this directory."

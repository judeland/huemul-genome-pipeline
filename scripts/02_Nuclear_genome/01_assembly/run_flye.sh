#!/usr/bin/env bash
set -euo pipefail

# Local equivalent of the Flye 2.9.6 assembly performed through Galaxy EU.
# The final analysis used the combined reads in Nanopore HQ mode, one internal
# polishing iteration, and a minimum read overlap of 1,000 bp. Graph-based
# scaffolding, metagenome mode, haplotype retention, and removal of alternative
# contigs were not enabled. All other Flye parameters retained their defaults.
#
# Requirements: Flye 2.9.6, assembly-stats, BUSCO 6.1.0, Miniprot, the
# combined FASTQ generated during read QC, and the downloaded
# cetartiodactyla_odb10 BUSCO lineage dataset.
# Run this script from the repository root.
# Output note: Flye reuses OUTPUT_DIR and BUSCO uses force mode. Change the
# output directory or BUSCO run name before rerunning to preserve old results.

COMBINED_READS="QC_reads/shehuen_coiron_reads.fastq.gz"
OUTPUT_DIR="Flye_assembly"
BUSCO_DOWNLOAD_DIR="busco_downloads"
THREADS=16  # Edit according to the available CPU resources

mkdir -p "$OUTPUT_DIR"

flye \
    --nano-hq "$COMBINED_READS" \
    --iterations 1 \
    --min-overlap 1000 \
    --threads "$THREADS" \
    --out-dir "$OUTPUT_DIR"

FLYE_ASSEMBLY="$OUTPUT_DIR/assembly.fasta"

# Basic assembly statistics.
ASSEMBLY_FASTA="$FLYE_ASSEMBLY" \
ASSEMBLY_STATS_OUTPUT="$OUTPUT_DIR/qc/assembly_stats/assembly_stats.txt" \
bash scripts/07_Shared_QC/assembly_stats.sh

# Genome completeness.
ASSEMBLY_FASTA="$FLYE_ASSEMBLY" \
BUSCO_RUN_NAME="busco_flye_draft" \
BUSCO_OUTPUT_DIR="$OUTPUT_DIR/qc/busco" \
BUSCO_DOWNLOAD_DIR="$BUSCO_DOWNLOAD_DIR" \
bash scripts/07_Shared_QC/busco/busco_genome.sh

echo "Flye draft assembly: $FLYE_ASSEMBLY"

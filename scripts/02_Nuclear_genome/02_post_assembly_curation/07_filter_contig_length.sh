#!/usr/bin/env bash
set -euo pipefail

# Removes contigs shorter than 20 kb after biological-contamination and
# mitochondrial screening. The 20-kb threshold is the definitive value used
# in the final analysis.
#
# Requirements: SeqKit, assembly-stats, BUSCO 6.1.0, Miniprot, the screened
# assembly, and the downloaded cetartiodactyla_odb10 BUSCO lineage dataset.
# Run this script from the repository root.
# Output note: files with the same names in OUTPUT_DIR and the BUSCO run are
# overwritten. Change the output directory or run name to preserve old results.

ASSEMBLY="Mitochondrial_screen/assembly_after_mitochondrial_screen.fasta"
OUTPUT_DIR="Length_filter"
BUSCO_DOWNLOAD_DIR="busco_downloads"

mkdir -p "$OUTPUT_DIR"

seqkit seq \
    --min-len 20000 \
    "$ASSEMBLY" \
    > "$OUTPUT_DIR/final_filtered_assembly.fasta"

FILTERED_ASSEMBLY="$OUTPUT_DIR/final_filtered_assembly.fasta"

# Basic assembly statistics.
ASSEMBLY_FASTA="$FILTERED_ASSEMBLY" \
ASSEMBLY_STATS_OUTPUT="$OUTPUT_DIR/qc/assembly_stats/assembly_stats.txt" \
bash scripts/07_Shared_QC/assembly_stats.sh

# Genome completeness after contamination screening and length filtering.
ASSEMBLY_FASTA="$FILTERED_ASSEMBLY" \
BUSCO_RUN_NAME="busco_cleaned_length_filtered" \
BUSCO_OUTPUT_DIR="$OUTPUT_DIR/qc/busco" \
BUSCO_DOWNLOAD_DIR="$BUSCO_DOWNLOAD_DIR" \
bash scripts/07_Shared_QC/busco/busco_genome.sh

echo "Length-filtered assembly: $FILTERED_ASSEMBLY"

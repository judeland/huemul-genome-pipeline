#!/usr/bin/env bash
set -euo pipefail

# Polishes the post-purge_dups assembly with Medaka 2.2.2 using the combined
# Oxford Nanopore reads and the model recorded for the final analysis.
# Batch size 50 is retained from the analysis records; it affects computational
# performance rather than the biological consensus model.
#
# Requirements: Medaka 2.2.2, assembly-stats, BUSCO 6.1.0, Miniprot, the
# combined ONT reads, the purged assembly, and the downloaded
# cetartiodactyla_odb10 BUSCO lineage dataset.
# Run this script from the repository root.
# Output note: files with the same names in OUTPUT_DIR and the BUSCO run are
# overwritten. Change the output directory or run name to preserve old results.

READS="QC_reads/shehuen_coiron_reads.fastq.gz"
ASSEMBLY="Purge_dups/assembly_purged.fasta"
OUTPUT_DIR="Medaka"
BUSCO_DOWNLOAD_DIR="busco_downloads"
THREADS=16  # Edit according to the available CPU resources

mkdir -p "$OUTPUT_DIR"

medaka_consensus \
    -i "$READS" \
    -d "$ASSEMBLY" \
    -o "$OUTPUT_DIR/medaka_output" \
    -m r1041_e82_400bps_sup_v5.0.0 \
    -b 50 \
    -t "$THREADS"

cp \
    "$OUTPUT_DIR/medaka_output/consensus.fasta" \
    "$OUTPUT_DIR/assembly_polished.fasta"

POLISHED_ASSEMBLY="$OUTPUT_DIR/assembly_polished.fasta"

# Basic assembly statistics.
ASSEMBLY_FASTA="$POLISHED_ASSEMBLY" \
ASSEMBLY_STATS_OUTPUT="$OUTPUT_DIR/qc/assembly_stats/assembly_stats.txt" \
bash scripts/07_Shared_QC/assembly_stats.sh

# Genome completeness.
ASSEMBLY_FASTA="$POLISHED_ASSEMBLY" \
BUSCO_RUN_NAME="busco_post_medaka" \
BUSCO_OUTPUT_DIR="$OUTPUT_DIR/qc/busco" \
BUSCO_DOWNLOAD_DIR="$BUSCO_DOWNLOAD_DIR" \
bash scripts/07_Shared_QC/busco/busco_genome.sh

echo "Medaka-polished assembly: $POLISHED_ASSEMBLY"

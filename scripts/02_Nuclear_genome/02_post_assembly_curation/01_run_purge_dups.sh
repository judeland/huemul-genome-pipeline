#!/usr/bin/env bash
set -euo pipefail

# Removes haplotypic duplications from the Flye draft with purge_dups 1.2.5.
# This workflow was reconstructed from the retained PAF-based outputs,
# coverage files, automatic cutoffs, and analysis records. Base-level depth
# profiles were generated with a maximum depth of 66x before automatic cutoff
# estimation with calcuts.
#
# Requirements: minimap2 2.31, purge_dups 1.2.5, assembly-stats, BUSCO 6.1.0,
# Miniprot, the combined ONT reads, the Flye assembly, and the downloaded
# cetartiodactyla_odb10 BUSCO lineage dataset.
# Run this script from the repository root.
# Output note: files with the same names in OUTPUT_DIR and the BUSCO run are
# overwritten. Change the output directory or run name to preserve old results.

READS="QC_reads/shehuen_coiron_reads.fastq.gz"
ASSEMBLY="Flye_assembly/assembly.fasta"
OUTPUT_DIR="Purge_dups"
BUSCO_DOWNLOAD_DIR="busco_downloads"
THREADS=16  # Edit according to the available CPU resources

mkdir -p "$OUTPUT_DIR/logs"

(
    cd "$OUTPUT_DIR"

    # Map the combined reads against the Flye draft.
    minimap2 \
        -x map-ont \
        -t "$THREADS" \
        "../$ASSEMBLY" \
        "../$READS" \
        | gzip -c > reads_vs_assembly.paf.gz

    # Calculate depth statistics and estimate the coverage cutoffs.
    pbcstat -M 66 reads_vs_assembly.paf.gz
    calcuts PB.stat > cutoffs 2> logs/calcuts.log

    # Generate the assembly self-alignment.
    split_fa "../$ASSEMBLY" > assembly.split

    minimap2 \
        -x asm5 \
        -DP \
        -t "$THREADS" \
        assembly.split \
        assembly.split \
        | gzip -c > self_aln.paf.gz

    # Identify and remove haplotypic duplications.
    purge_dups \
        -2 \
        -T cutoffs \
        -c PB.base.cov \
        self_aln.paf.gz \
        > dups.bed \
        2> logs/purge_dups.log

    get_seqs \
        -e dups.bed \
        "../$ASSEMBLY"

    mv purged.fa assembly_purged.fasta
)

PURGED_ASSEMBLY="$OUTPUT_DIR/assembly_purged.fasta"

# Basic assembly statistics.
ASSEMBLY_FASTA="$PURGED_ASSEMBLY" \
ASSEMBLY_STATS_OUTPUT="$OUTPUT_DIR/qc/assembly_stats/assembly_stats.txt" \
bash scripts/07_Shared_QC/assembly_stats.sh

# Genome completeness.
ASSEMBLY_FASTA="$PURGED_ASSEMBLY" \
BUSCO_RUN_NAME="busco_post_purge_dups" \
BUSCO_OUTPUT_DIR="$OUTPUT_DIR/qc/busco" \
BUSCO_DOWNLOAD_DIR="$BUSCO_DOWNLOAD_DIR" \
bash scripts/07_Shared_QC/busco/busco_genome.sh

echo "Purged assembly: $PURGED_ASSEMBLY"

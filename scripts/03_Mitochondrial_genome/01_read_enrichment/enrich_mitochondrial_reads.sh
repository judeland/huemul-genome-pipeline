#!/usr/bin/env bash
set -euo pipefail

# Enriches mitochondrial Oxford Nanopore reads before de novo mitochondrial
# genome assembly.
#
# Workflow used in this study:
# 1. Retain reads between 5,000 and 16,500 bp with Filtlong.
# 2. Align the retained reads against the Hippocamelus antisensis complete
#    mitochondrial genome (NC_020711.1) with minimap2.
# 3. Retain only mapped reads and convert them back to FASTQ with SAMtools.
#
# Programs used: Filtlong, minimap2, SAMtools, SeqKit, and gzip.
#
# Versions used in the huemul analysis:
# - Filtlong 0.3.1
# - minimap2 2.31
# - SAMtools 1.23.1
# - SeqKit 2.13.0
#
# Complete software provenance is summarized in SOFTWARE.md.
#
# Reusing OUTPUT_DIR overwrites files with the same names.

INPUT_READS="reads/Shehuen.fastq.gz"
MITOCHONDRIAL_REFERENCE="references/mitochondrial/individual/Hippocamelus_antisensis_NC_020711.1.fasta"

OUTPUT_DIR="mitochondrial_assembly/input_reads"
THREADS=16

SIZE_FILTERED_READS="${OUTPUT_DIR}/mitochondrial_length_reads.fastq.gz"
ALIGNMENT="${OUTPUT_DIR}/mitochondrial_read_alignments.bam"
ENRICHED_READS="${OUTPUT_DIR}/mitochondrial_enriched_reads.fastq.gz"

mkdir -p "$OUTPUT_DIR"

filtlong \
    --min_length 5000 \
    --max_length 16500 \
    "$INPUT_READS" \
    | gzip \
    > "$SIZE_FILTERED_READS"

minimap2 \
    -ax map-ont \
    --secondary=no \
    -p 0.9 \
    -s 100 \
    -t "$THREADS" \
    "$MITOCHONDRIAL_REFERENCE" \
    "$SIZE_FILTERED_READS" \
    | samtools view \
        -@ "$THREADS" \
        -b \
        -F 4 \
        -o "$ALIGNMENT"

samtools fastq \
    -@ "$THREADS" \
    "$ALIGNMENT" \
    | gzip \
    > "$ENRICHED_READS"

seqkit stats \
    -a \
    "$ENRICHED_READS" \
    > "${OUTPUT_DIR}/mitochondrial_enriched_reads_stats.txt"

echo "Mitochondrial-enriched reads: $ENRICHED_READS"

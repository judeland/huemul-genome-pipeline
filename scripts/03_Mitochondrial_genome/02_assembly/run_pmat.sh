#!/usr/bin/env bash
set -euo pipefail

# Assembles the mitochondrial genome from enriched Oxford Nanopore reads using
# PMAT v2.1.5 in autoMito mode with Canu v2.2 as the assembly backend.
#
# Historical parameters:
# - Oxford Nanopore reads
# - expected mitochondrial genome size: 16,400 bp
# - mitochondrial genome mode
# - Canu backend
# - 16 threads
#
# Requirements: PMAT 2.1.5, Canu 2.2, BLAST+ 2.17.0+, and Singularity.
#
# Reusing OUTPUT_DIR may overwrite or mix results from previous runs.

MITOCHONDRIAL_READS="mitochondrial_assembly/input_reads/mitochondrial_enriched_reads.fastq.gz"
OUTPUT_DIR="mitochondrial_assembly/pmat"
THREADS=16

PMAT autoMito \
    -i "$MITOCHONDRIAL_READS" \
    -o "$OUTPUT_DIR" \
    -t ont \
    -g 16400 \
    -p 1 \
    -G mt \
    -x 1 \
    -S canu \
    -C "$(which canu)" \
    -T "$THREADS"

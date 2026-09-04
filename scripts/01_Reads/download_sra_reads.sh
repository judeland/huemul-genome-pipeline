#!/usr/bin/env bash
set -euo pipefail

# Downloads the Oxford Nanopore FASTQ files used in this project.
#
# Program used: wget.
# Run this script from the repository root.
# Existing files with the same names are overwritten.

OUTPUT_DIR="reads"

mkdir -p "$OUTPUT_DIR"

wget \
    -O "$OUTPUT_DIR/Shehuen.fastq.gz" \
    "https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR400/082/SRR40078882/SRR40078882.fastq.gz"

wget \
    -O "$OUTPUT_DIR/Coiron.fastq.gz" \
    "https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR400/081/SRR40078881/SRR40078881.fastq.gz"

echo "Downloaded reads:"
echo "$OUTPUT_DIR/Shehuen.fastq.gz"
echo "$OUTPUT_DIR/Coiron.fastq.gz"

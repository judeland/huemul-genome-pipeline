#!/usr/bin/env bash
set -euo pipefail

# Reference-guided scaffolding with RagTag 2.1.0 against the O. virginianus
# Ovbor_1.2 reference. Unplaced sequences are concatenated into Chr0 with -C.
# Assembly QC (assembly-stats, BUSCO, QUAST) is run on the final NCBI-ready
# assembly in 10_build_ncbi_submission.sh.
#
# Requirements: RagTag 2.1.0, minimap2, the final FCS-adaptor-cleaned assembly,
# and the O. virginianus genomic reference.
# Run this script from the repository root.
# Output note: RagTag reuses its output directory. Change it before rerunning
# to preserve results.

REFERENCE="references/genomic/GCF_023699985.2_Ovbor_1.2_genomic.fna"
ASSEMBLY="FCS_adaptor/assembly_FCS_adaptor_clean.fasta"
OUTPUT_DIR="RagTag"
THREADS=16  # Edit according to the available CPU resources

MM2_PARAMETERS="-x asm5 -k19 -w19 -A1 -B19 -O39,81 -E3,1 -s200 -z200 --min-occ-floor=100 -t ${THREADS}"

mkdir -p "$OUTPUT_DIR"

ragtag.py scaffold \
    "$REFERENCE" \
    "$ASSEMBLY" \
    --output "$OUTPUT_DIR" \
    --threads "$THREADS" \
    --mm2-params "$MM2_PARAMETERS" \
    -f 1000 \
    --remove-small \
    -q 10 \
    -C

echo "RagTag scaffolded assembly: $OUTPUT_DIR/ragtag.scaffold.fasta"

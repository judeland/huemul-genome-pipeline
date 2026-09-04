#!/usr/bin/env bash
set -euo pipefail

# Applies the biological-contamination Action report generated with NCBI
# FCS-GX on Galaxy EU. The final Galaxy screening used FCS-GX 0.5.5+galaxy2,
# database fcs-2023-01-24, TaxID 397614, species Hippocamelus bisulcus,
# FASTA splitting at N-runs enabled, no manual taxonomic exclusions, and
# same-kingdom contamination retained. Only records explicitly marked EXCLUDE
# in the retained Action report are removed here.
#
# Requirements: SeqKit, the Medaka-polished assembly, and the FCS-GX Action
# report downloaded from Galaxy.
# Output note: files with the same names in OUTPUT_DIR are overwritten.

ASSEMBLY="Medaka/assembly_polished.fasta"
ACTION_REPORT="FCS_GX/FCS_GX_action_report.tsv"
OUTPUT_DIR="FCS_GX"

mkdir -p "$OUTPUT_DIR"

# Extract sequence identifiers explicitly marked EXCLUDE.
awk -F '\t' \
    '!/^#/ && $5 == "EXCLUDE" {print $1}' \
    "$ACTION_REPORT" \
    | sort -u \
    > "$OUTPUT_DIR/contigs_to_exclude.txt"

# Remove only the sequences listed by FCS-GX.
seqkit grep \
    -v \
    -f "$OUTPUT_DIR/contigs_to_exclude.txt" \
    "$ASSEMBLY" \
    > "$OUTPUT_DIR/assembly_post_FCS_GX.fasta"

echo "Excluded sequences:"
wc -l "$OUTPUT_DIR/contigs_to_exclude.txt"
echo "Post-FCS-GX assembly: $OUTPUT_DIR/assembly_post_FCS_GX.fasta"

#!/usr/bin/env bash
set -euo pipefail

# Produces a stable post-screening assembly. Add one exact FASTA identifier per
# line to contigs_to_remove.txt only if a complete mitochondrial contig has
# been confidently identified. The file remained empty in the final analysis,
# so the screened nuclear assembly was retained unchanged.
#
# Requirements: SeqKit and the post-FCS-GX assembly.
# Output note: assembly_after_mitochondrial_screen.fasta is overwritten.

ASSEMBLY="FCS_GX/assembly_post_FCS_GX.fasta"
IDS_TO_REMOVE="Mitochondrial_screen/contigs_to_remove.txt"
OUTPUT_DIR="Mitochondrial_screen"
OUTPUT_ASSEMBLY="$OUTPUT_DIR/assembly_after_mitochondrial_screen.fasta"

mkdir -p "$OUTPUT_DIR"
touch "$IDS_TO_REMOVE"

if [[ -s "$IDS_TO_REMOVE" ]]; then
    echo "Removing the following mitochondrial contigs:"
    cat "$IDS_TO_REMOVE"

    seqkit grep \
        -v \
        -f "$IDS_TO_REMOVE" \
        "$ASSEMBLY" \
        > "$OUTPUT_ASSEMBLY"
else
    echo "No complete mitochondrial contigs were selected for removal."
    cp "$ASSEMBLY" "$OUTPUT_ASSEMBLY"
fi

echo "Post-screening assembly: $OUTPUT_ASSEMBLY"

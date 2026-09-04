#!/usr/bin/env bash
set -euo pipefail

# Generates the nuclear-only Odocoileus virginianus reference used for LiftOn
# annotation, so that mitochondrial genes are not transferred onto NUMTs. The
# mitochondrial record NC_015247.1 is removed from both the genomic FASTA and
# its GFF3 annotation.
#
# Requirements: samtools, the complete O. virginianus reference genome, and
# its matching genomic GFF3 annotation.
# Output note: files with the same names in OUTPUT_DIR are overwritten.

REFERENCE_FASTA="references/genomic/GCF_023699985.2_Ovbor_1.2_genomic.fna"
REFERENCE_GFF="references/genomic/GCF_023699985.2_Ovbor_1.2_genomic.gff"
OUTPUT_DIR="references/genomic/nuclear"
MITOCHONDRIAL_ACCESSION="NC_015247.1"

mkdir -p "$OUTPUT_DIR"

NUCLEAR_SEQUENCE_IDS="$OUTPUT_DIR/Ovbor_1.2_nuclear_sequence_ids.txt"
NUCLEAR_FASTA="$OUTPUT_DIR/Ovbor_1.2_nuclear.fna"
NUCLEAR_GFF="$OUTPUT_DIR/Ovbor_1.2_nuclear.gff3"

# Retain every reference sequence except the mitochondrial replicon.
grep '^>' "$REFERENCE_FASTA" \
    | cut -d' ' -f1 \
    | sed 's/^>//' \
    | grep -Fvx "$MITOCHONDRIAL_ACCESSION" \
    > "$NUCLEAR_SEQUENCE_IDS"

# Extract the nuclear reference sequences.
samtools faidx "$REFERENCE_FASTA"
samtools faidx \
    --region-file "$NUCLEAR_SEQUENCE_IDS" \
    --output "$NUCLEAR_FASTA" \
    "$REFERENCE_FASTA"

# Remove the mitochondrial record and its sequence-region directive from GFF3.
awk -v mito="$MITOCHONDRIAL_ACCESSION" '
    /^##sequence-region[[:space:]]/ { if ($2 != mito) print; next }
    /^#/ { print; next }
    $1 != mito { print }
' "$REFERENCE_GFF" > "$NUCLEAR_GFF"

samtools faidx "$NUCLEAR_FASTA"

echo "Nuclear reference FASTA: $NUCLEAR_FASTA"
echo "Nuclear reference GFF3:  $NUCLEAR_GFF"

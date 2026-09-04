#!/usr/bin/env bash
set -euo pipefail

# Processes the final nuclear LiftOn annotation with AGAT 1.7.0. Both the full
# proteome and a representative proteome containing the longest protein
# isoform per gene are generated. Stop-codon cleaning options are deliberately
# not applied, matching the final analysis used in the manuscript.
#
# Requirements: AGAT 1.7.0, the LiftOn GFF3 annotation, and the same final
# H. bisulcus assembly used during annotation transfer.
# Output note: change OUTPUT_DIR before rerunning to preserve previous results.

ANNOTATION="lifton_output/Hbis_nuclear_annotation_LiftOn.gff3"
ASSEMBLY="NCBI_submission/Hbis_scaffolds_NCBI.fasta"
OUTPUT_DIR="agat_output"

mkdir -p "$OUTPUT_DIR"

REPRESENTATIVE_GFF="$OUTPUT_DIR/Hbis_nuclear_annotation_longest_isoform.gff3"
ALL_PROTEINS="$OUTPUT_DIR/Hbis_complete_proteome_all_isoforms.faa"
REPRESENTATIVE_PROTEINS="$OUTPUT_DIR/Hbis_representative_proteome_longest_isoform.faa"

agat_sp_statistics.pl \
    --gff "$ANNOTATION" \
    --output "$OUTPUT_DIR/AGAT_statistics_full_annotation.txt"

agat_sp_keep_longest_isoform.pl \
    --gff "$ANNOTATION" \
    --output "$REPRESENTATIVE_GFF"

agat_sp_statistics.pl \
    --gff "$REPRESENTATIVE_GFF" \
    --output "$OUTPUT_DIR/AGAT_statistics_representative_annotation.txt"

agat_sp_extract_sequences.pl \
    --gff "$ANNOTATION" \
    --fasta "$ASSEMBLY" \
    --protein \
    --output "$ALL_PROTEINS"

agat_sp_extract_sequences.pl \
    --gff "$REPRESENTATIVE_GFF" \
    --fasta "$ASSEMBLY" \
    --protein \
    --output "$REPRESENTATIVE_PROTEINS"

echo "Complete proteome: $ALL_PROTEINS"
echo "Representative proteome: $REPRESENTATIVE_PROTEINS"

# Proteome completeness assessment

QC_SCRIPT="scripts/07_Shared_QC/busco/busco_proteome.sh"

PROTEOME_FASTA="$REPRESENTATIVE_PROTEINS" \
BUSCO_RUN_NAME="busco_Hbis_representative_proteome" \
BUSCO_OUTPUT_DIR="$OUTPUT_DIR/qc/busco" \
BUSCO_DOWNLOAD_DIR="busco_downloads" \
bash "$QC_SCRIPT"

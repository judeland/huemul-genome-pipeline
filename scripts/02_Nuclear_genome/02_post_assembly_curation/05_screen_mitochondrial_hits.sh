#!/usr/bin/env bash
set -euo pipefail

# Screens the post-FCS-GX nuclear assembly against a doubled copy of the
# complete H. bisulcus mitochondrial genome. Doubling accounts for circularity
# and avoids edge effects at the linearized mitochondrial boundary. This is a
# diagnostic step: it reports matches but does not remove sequences. In the
# final analysis, 64 nuclear contigs contained partial matches compatible with
# NUMTs.
#
# Requirements: BLAST+, the post-FCS-GX assembly, and the complete H. bisulcus
# mitochondrial genome.
# Output note: files with the same names in OUTPUT_DIR are overwritten.

ASSEMBLY="FCS_GX/assembly_post_FCS_GX.fasta"
MITOGENOME="mitochondrial_assembly/Hbis_complete_mitochondrial_genome.fasta"
OUTPUT_DIR="Mitochondrial_screen"
THREADS=16  # Edit according to the available CPU resources

mkdir -p "$OUTPUT_DIR"

DOUBLED_MITOGENOME="$OUTPUT_DIR/Hbis_mitogenome_doubled.fasta"

awk '
    /^>/ { next }
    { sequence = sequence $0 }
    END {
        print ">Hippocamelus_bisulcus_mitogenome_doubled"
        print sequence sequence
    }
' "$MITOGENOME" > "$DOUBLED_MITOGENOME"

makeblastdb \
    -in "$DOUBLED_MITOGENOME" \
    -dbtype nucl \
    -out "$OUTPUT_DIR/mitogenome_db"

blastn \
    -query "$ASSEMBLY" \
    -db "$OUTPUT_DIR/mitogenome_db" \
    -task megablast \
    -evalue 0.001 \
    -num_threads "$THREADS" \
    -strand both \
    -dust yes \
    -outfmt "6 qseqid pident length qstart qend qlen sstart send slen evalue bitscore" \
    -out "$OUTPUT_DIR/mitogenome_hits.tsv"

cut -f1 "$OUTPUT_DIR/mitogenome_hits.tsv" \
    | sort -u \
    > "$OUTPUT_DIR/contigs_with_mitochondrial_hits.txt"

echo "Contigs with mitochondrial matches:"
wc -l "$OUTPUT_DIR/contigs_with_mitochondrial_hits.txt"

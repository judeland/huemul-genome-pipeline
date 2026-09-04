#!/usr/bin/env bash
set -euo pipefail

# Rotates the circular mitochondrial genome recovered with PMAT2 to the
# conventional mitochondrial coordinate origin used for annotation and
# comparison with the reference sequences.
#
# Comparison with the normalized final sequence showed that:
# - both sequences had the same strand orientation;
# - PMAT2 positions 15744-16405 became positions 1-662;
# - PMAT2 positions 1-15743 became positions 663-16405;
# - no nucleotides were added, removed, or reverse-complemented.
#
# Requirement: SeqKit.

PMAT_MITOGENOME="mitochondrial_assembly/pmat/gfa_result/PMAT_mt.fa"
NORMALIZED_MITOGENOME="mitochondrial_assembly/Hbis_complete_mitochondrial_genome.fasta"

START_POSITION=15744

seqkit restart \
    -i "$START_POSITION" \
    "$PMAT_MITOGENOME" \
    | seqkit replace \
        -p "^.*$" \
        -r "Hippocamelus_bisulcus_mitochondrion" \
    > "$NORMALIZED_MITOGENOME"

seqkit stats \
    -a \
    "$PMAT_MITOGENOME" \
    "$NORMALIZED_MITOGENOME"

seqkit sum \
    --circular \
    "$PMAT_MITOGENOME" \
    "$NORMALIZED_MITOGENOME"

#!/usr/bin/env bash
set -euo pipefail

# Converts the final RagTag FASTA and AGP into the NCBI-ready H. bisulcus
# assembly. Chr0 is decomposed into its original unplaced components, and all
# chromosome, scaffold, and unplaced-contig identifiers are standardized.
# The expected final composition is 36 chromosomes, 119 unlocalized scaffolds,
# and 187 unplaced contigs, totaling 342 sequences.
#
# Requirements: Python 3, build_ncbi_submission.py, assembly-stats, BUSCO 6.1.0,
# Miniprot, QUAST, the final RagTag FASTA and AGP, the nuclear O. virginianus
# reference, and the downloaded cetartiodactyla_odb10 BUSCO lineage dataset.
# Run this script from the repository root.
# Output note: files with the same names in OUTPUT_DIR and the BUSCO run are
# overwritten. Change the output directory or run name to preserve old results.

RAGTAG_FASTA="RagTag/ragtag.scaffold.fasta"
RAGTAG_AGP="RagTag/ragtag.scaffold.agp"
NUCLEAR_REFERENCE="references/genomic/nuclear/Ovbor_1.2_nuclear.fna"
OUTPUT_DIR="NCBI_submission"
BUSCO_DOWNLOAD_DIR="busco_downloads"

mkdir -p "$OUTPUT_DIR"

python3 scripts/02_Nuclear_genome/03_scaffolding/build_ncbi_submission.py \
    --agp "$RAGTAG_AGP" \
    --fasta "$RAGTAG_FASTA" \
    --output-dir "$OUTPUT_DIR"

FINAL_ASSEMBLY="$OUTPUT_DIR/Hbis_scaffolds_NCBI.fasta"

# Basic statistics for the final NCBI-ready assembly.
ASSEMBLY_FASTA="$FINAL_ASSEMBLY" \
ASSEMBLY_STATS_OUTPUT="$OUTPUT_DIR/qc/assembly_stats/assembly_stats.txt" \
bash scripts/07_Shared_QC/assembly_stats.sh

# Genome completeness of the final NCBI-ready assembly.
ASSEMBLY_FASTA="$FINAL_ASSEMBLY" \
BUSCO_RUN_NAME="busco_final_NCBI_assembly" \
BUSCO_OUTPUT_DIR="$OUTPUT_DIR/qc/busco" \
BUSCO_DOWNLOAD_DIR="$BUSCO_DOWNLOAD_DIR" \
bash scripts/07_Shared_QC/busco/busco_genome.sh

# Final QUAST assessment against the nuclear O. virginianus reference.
ASSEMBLY_FASTA="$FINAL_ASSEMBLY" \
REFERENCE_FASTA="$NUCLEAR_REFERENCE" \
QUAST_OUTPUT_DIR="$OUTPUT_DIR/qc/quast_vs_reference" \
bash scripts/07_Shared_QC/quast.sh

echo "Final NCBI-ready assembly: $FINAL_ASSEMBLY"

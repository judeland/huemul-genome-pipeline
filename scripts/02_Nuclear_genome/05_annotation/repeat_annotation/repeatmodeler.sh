#!/usr/bin/env bash
set -euo pipefail

# Local equivalent of the RepeatModeler 2.0.5 analysis performed on
# usegalaxy.eu. RepeatModeler is computationally intensive for mammalian
# genomes and may require substantial RAM, disk space, and runtime.
#
# Reproducibility note: an independent local run with nominally equivalent
# parameters produced a slightly different consensus library and a larger
# unclassified fraction (1.27% locally versus 0.87% on Galaxy). Exact library
# content can depend on the versions of bundled databases, classification
# resources, and auxiliary programs. The library generated on usegalaxy.eu
# and deposited with this project is therefore the canonical library used for
# the reported RepeatMasker analysis.
#
# Requirements: RepeatModeler 2.0.5 and the final H. bisulcus assembly.
# Output note: change OUTPUT_DIR before rerunning to preserve previous results.

GENOME_FASTA="NCBI_submission/Hbis_scaffolds_NCBI.fasta"
OUTPUT_DIR="repeatmodeler"
DATABASE_NAME="rmdb"
THREADS=16

mkdir -p "${OUTPUT_DIR}"

BuildDatabase \
    -name "${OUTPUT_DIR}/${DATABASE_NAME}" \
    "${GENOME_FASTA}" \
    2>&1 | tee "${OUTPUT_DIR}/build_database.log"

RepeatModeler \
    -database "${OUTPUT_DIR}/${DATABASE_NAME}" \
    -threads "$THREADS" \
    2>&1 | tee "${OUTPUT_DIR}/repeatmodeler.log"

# Copy the consensus library to the filename expected by repeatmasker.sh so the
# two scripts chain end to end. NOTE: for the results reported in the manuscript
# the canonical library is the deposited Galaxy-derived one (see note above);
# this local copy will differ slightly. Replace it with the deposited library to
# reproduce the reported RepeatMasker summary exactly.
cp "${OUTPUT_DIR}/${DATABASE_NAME}-families.fa" \
    "${OUTPUT_DIR}/Hbis_RepeatModeler_consensus_library.fasta"

echo "RepeatModeler completed."
echo "Consensus library: ${OUTPUT_DIR}/Hbis_RepeatModeler_consensus_library.fasta"
echo "Seed alignments:   ${OUTPUT_DIR}/${DATABASE_NAME}-families.stk"

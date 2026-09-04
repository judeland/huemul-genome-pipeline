#!/usr/bin/env bash
set -euo pipefail

# Local equivalent of the RepeatMasker 4.1.5 analysis performed on
# usegalaxy.eu with the de novo RepeatModeler consensus library.
# Use the deposited Galaxy-derived consensus library to reproduce the repeat
# summary reported in the manuscript. A separately regenerated local library
# may produce slightly different classifications even with the same principal
# command-line parameters.
#
# Requirements: RepeatMasker 4.1.5, the final H. bisulcus assembly, and the
# deposited RepeatModeler consensus library generated on usegalaxy.eu.
# Output note: change OUTPUT_DIR before rerunning to preserve previous results.

# REPEAT_LIBRARY: place the deposited Galaxy-derived consensus library here to
# reproduce the reported summary exactly. repeatmodeler.sh also writes a local
# copy under this same name if you regenerate the library de novo.
GENOME_FASTA="NCBI_submission/Hbis_scaffolds_NCBI.fasta"
REPEAT_LIBRARY="repeatmodeler/Hbis_RepeatModeler_consensus_library.fasta"
OUTPUT_DIR="repeatmasker"
THREADS=16

mkdir -p "${OUTPUT_DIR}"

RepeatMasker \
    -dir "${OUTPUT_DIR}" \
    -lib "${REPEAT_LIBRARY}" \
    -cutoff 225 \
    -parallel "$THREADS" \
    -gff \
    -excln \
    -frag 40000 \
    -xsmall \
    "${GENOME_FASTA}" \
    2>&1 | tee "${OUTPUT_DIR}/repeatmasker.log"

echo "RepeatMasker completed."
echo "Results directory: ${OUTPUT_DIR}"

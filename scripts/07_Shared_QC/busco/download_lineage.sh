#!/usr/bin/env bash
set -euo pipefail

# Downloads the Cetartiodactyla BUSCO lineage dataset used for all genome- and
# protein-mode completeness assessments in the project. Run this script once
# with internet access; subsequent BUSCO analyses use the dataset offline.
#
# Requirements: BUSCO 6.1.0 and internet access.
# The downloaded lineage is not intended for inclusion in the GitHub repository.

BUSCO_DOWNLOAD_DIR="busco_downloads"

mkdir -p "$BUSCO_DOWNLOAD_DIR"

busco \
    --download cetartiodactyla_odb10 \
    --download_path "$BUSCO_DOWNLOAD_DIR"

echo "BUSCO lineage directory: $BUSCO_DOWNLOAD_DIR/cetartiodactyla_odb10"

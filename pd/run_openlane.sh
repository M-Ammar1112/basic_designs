#!/bin/bash
# =============================================================================
# OpenLane 2 ASIC Physical Design Runner
# Usage: ./pd/run_openlane.sh <design_name>
# Example: ./pd/run_openlane.sh gcd_top
# =============================================================================

set -e

DESIGN="${1:-gcd_top}"
CONFIG_DIR="pd/${DESIGN}"

if [ ! -d "$CONFIG_DIR" ]; then
    echo "Error: Configuration directory '$CONFIG_DIR' not found."
    echo "Available designs with OpenLane configs:"
    for d in pd/*/; do
        if [ -f "${d}config.json" ]; then
            basename "$d"
        fi
    done
    exit 1
fi

OPENLANE_PATH="${OPENLANE_PATH:-$HOME/projects/opensource/openlane2}"

if [ ! -d "$OPENLANE_PATH" ]; then
    echo "Error: OPENLANE_PATH directory not found at $OPENLANE_PATH"
    echo "Please set OPENLANE_PATH environment variable or install OpenLane 2."
    exit 1
fi

ABS_CONFIG="$(realpath "$CONFIG_DIR/config.json")"
echo "==> Running OpenLane 2 for design: $DESIGN"
echo "==> Config: $ABS_CONFIG"
echo "==> OpenLane Path: $OPENLANE_PATH"

cd "$OPENLANE_PATH"
if command -v nix &> /dev/null; then
    nix --experimental-features "nix-command flakes" develop --command python3 -m openlane "$ABS_CONFIG"
else
    python3 -m openlane "$ABS_CONFIG"
fi
cd - > /dev/null

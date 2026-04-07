#!/bin/bash
# =============================================================
# run_inflation.sh
#
# Runs the map inflation algorithm for one or multiple kernel
# sizes on a given occupancy grid JSON file.
#
# Usage:
#   ./run_inflation.sh --input <map.json> --kernels "3 5 7 9"
#
# Arguments:
#   --input    path to the input JSON file (required)
#   --kernels  space-separated list of kernel sizes (default: "3 5 7 9")
#   --outdir   output directory for images (default: ./inflation_outputs)
#   --script   path to inflate_occupancy_grid.py (default: ./inflate_occupancy_grid.py)
#
# Example:
#   ./run_inflation.sh --input map_data.json --kernels "3 5"
#   ./run_inflation.sh --input map_data.json --kernels "3 5 7 9" --outdir results/
# =============================================================

set -e

# --- defaults ---
INPUT="map_data3.json"
KERNELS="3 5 7"
OUTDIR="./inflation_outputs"
SCRIPT="./inflate_occupancy_grid.py"

# --- parse arguments ---
while [[ $# -gt 0 ]]; do
    case "$1" in
        --input)   INPUT="$2";   shift 2 ;;
        --kernels) KERNELS="$2"; shift 2 ;;
        --outdir)  OUTDIR="$2";  shift 2 ;;
        --script)  SCRIPT="$2";  shift 2 ;;
        --help)
            echo "Usage: $0 --input <map.json> [--kernels \"3 5 7 9\"] [--outdir <dir>]"
            echo ""
            echo "  --input    path to the input JSON file             (required)"
            echo "  --kernels  space-separated list of kernel sizes    (default: \"3 5 7 9\")"
            echo "  --outdir   output directory for result images      (default: ./inflation_outputs)"
            echo "  --script   path to inflate_occupancy_grid.py      (default: ./inflate_occupancy_grid.py)"
            echo ""
            echo "Examples:"
            echo "  $0 --input map_data.json"
            echo "  $0 --input map_data.json --kernels \"3 5\""
            echo "  $0 --input map_data.json --kernels \"3 5 7 9\" --outdir results/"
            exit 0
            ;;
        *)
            echo "Unknown argument: $1"
            echo "Run '$0 --help' for usage."
            exit 1
            ;;
    esac
done

# --- validate ---
if [[ -z "$INPUT" ]]; then
    echo "Error: --input is required."
    echo "Run '$0 --help' for usage."
    exit 1
fi

if [[ ! -f "$INPUT" ]]; then
    echo "Error: input file '$INPUT' not found."
    exit 1
fi

if [[ ! -f "$SCRIPT" ]]; then
    echo "Error: Python script '$SCRIPT' not found."
    echo "Pass the correct path with --script."
    exit 1
fi

# --- create output directory ---
mkdir -p "$OUTDIR"

echo "=============================================="
echo "  Map Inflation Pipeline"
echo "  Input   : $INPUT"
echo "  Kernels : $KERNELS"
echo "  Output  : $OUTDIR/"
echo "=============================================="
echo ""

# --- run for each kernel size ---
for K in $KERNELS; do
    OUTPUT="${OUTDIR}/inflation_result_K${K}.png"

    echo "----------------------------------------------"
    echo "  Kernel size : ${K}x${K}"
    echo "  Output file : ${OUTPUT}"
    echo "----------------------------------------------"

    python3 "$SCRIPT" "$INPUT" "$K" "$OUTPUT"

    echo ""
done

echo "=============================================="
echo "  All runs complete."
echo "  Results saved in: $OUTDIR/"
echo ""
for K in $KERNELS; do
    echo "    inflation_result_K${K}.png"
done
echo "=============================================="

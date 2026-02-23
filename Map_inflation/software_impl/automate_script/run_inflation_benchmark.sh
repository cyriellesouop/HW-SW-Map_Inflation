#!/bin/bash
# =============================================================
# run_inflation_benchmark.sh
#
# Compiles and runs the map inflation benchmark for every
# combination of matrix size and obstacle step provided.
#
# Usage:
#   ./run_inflation_benchmark.sh \
#       --sizes "500 1000 2000" \
#       --steps "10000 50000 100000"
#
# Each run produces a folder named:
#   Inflated_{H}x{W}_Obstacle_{step}
# containing the CSV, generated.json, and result.json files.
#
# Requirements: gcc, standard C library with -lrt (POSIX clock)
# =============================================================

set -e  # exit immediately on any error

# ------------------------------------------------------------------
# Default values (used if no arguments are provided)
# ------------------------------------------------------------------
SIZES="1000 2000"
STEPS="1500 2500 4000"
SOURCE="map_inflation.c"

# ------------------------------------------------------------------
# Parse named arguments
# ------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
    case "$1" in
        --sizes)
            SIZES="$2"
            shift 2
            ;;
        --steps)
            STEPS="$2"
            shift 2
            ;;
        --source)
            SOURCE="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [--sizes \"H1 H2 ...\"] [--steps \"S1 S2 ...\"] [--source file.c]"
            echo ""
            echo "  --sizes   Space-separated list of square matrix sizes (H=W)"
            echo "            Default: \"500 1000 2000\""
            echo "  --steps   Space-separated list of obstacle step values"
            echo "            Default: \"10000 50000\""
            echo "  --source  Path to the C source file"
            echo "            Default: map_inflation_improved.c"
            echo ""
            echo "Output folders: Inflated_{size}x{size}_Obstacle_{step}/"
            exit 0
            ;;
        *)
            echo "Unknown argument: $1"
            echo "Run '$0 --help' for usage."
            exit 1
            ;;
    esac
done

# ------------------------------------------------------------------
# Validate source file exists
# ------------------------------------------------------------------
if [[ ! -f "$SOURCE" ]]; then
    echo "ERROR: Source file '$SOURCE' not found."
    echo "Place the C file in the same directory as this script,"
    echo "or pass its path with --source."
    exit 1
fi

echo "=============================================="
echo "  Map Inflation Benchmark"
echo "  Source  : $SOURCE"
echo "  Sizes   : $SIZES"
echo "  Steps   : $STEPS"
echo "=============================================="
echo ""

# ------------------------------------------------------------------
# Main loop over all size x step combinations
# ------------------------------------------------------------------
for SIZE in $SIZES; do
    for STEP in $STEPS; do

        FOLDER="Inflated_${SIZE}x${SIZE}_Obstacle_${STEP}"
        BINARY="./inflation_${SIZE}x${SIZE}_step${STEP}"
        CSV_FILE="inflation_results_${SIZE}x${SIZE}_step${STEP}.csv"

        echo "----------------------------------------------"
        echo "  Matrix : ${SIZE}x${SIZE}"
        echo "  Step   : ${STEP}"
        echo "  Folder : ${FOLDER}/"
        echo "----------------------------------------------"

        # --- compile with matrix size and step as defines ---
        echo "[1/3] Compiling..."
        gcc -O2 \
            -DH=${SIZE} \
            -DW=${SIZE} \
            -DOBS_STEP=${STEP} \
            -o "$BINARY" \
            "$SOURCE" \
            -lm
        echo "      -> Binary: $BINARY"

        # --- run the benchmark ---
        echo "[2/3] Running benchmark..."
        "$BINARY"

        # --- collect outputs into the output folder ---
        echo "[3/3] Collecting outputs into ${FOLDER}/"
        mkdir -p "$FOLDER"

        # move CSV (filename includes size and step, set by the C code)
        if [[ -f "$CSV_FILE" ]]; then
            mv "$CSV_FILE" "${FOLDER}/"
            echo "      -> Moved $CSV_FILE"
        else
            echo "      WARNING: $CSV_FILE not found — skipping."
        fi

        # move JSON files
        for JSON_FILE in generated.json result.json; do
            if [[ -f "$JSON_FILE" ]]; then
                mv "$JSON_FILE" "${FOLDER}/"
                echo "      -> Moved $JSON_FILE"
            else
                echo "      WARNING: $JSON_FILE not found — skipping."
            fi
        done

        # remove the binary for this configuration
        rm -f "$BINARY"

        echo "      Done. Outputs in ${FOLDER}/"
        echo ""

    done
done

echo "=============================================="
echo "  All runs complete."
echo "  Output folders created:"
for SIZE in $SIZES; do
    for STEP in $STEPS; do
        echo "    Inflated_${SIZE}x${SIZE}_Obstacle_${STEP}/"
    done
done
echo "=============================================="

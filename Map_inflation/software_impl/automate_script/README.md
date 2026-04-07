ls # Map Inflation Benchmark

## Overview

This project implements and benchmarks a **map inflation algorithm** used in robotic navigation. In robotics, a raw occupancy grid marks obstacle cells with a lethal value. Inflation expands each obstacle outward using a weighted kernel, creating a cost gradient around obstacles that path planners use to maintain safe clearance.

The primary goal of this benchmark is to **measure the CPU time spent performing element-wise matrix multiplications** during inflation, so that result can be compared against an FPGA hardware accelerator designed to offload that exact operation.

---
## Computer Specification 

### CPU Architecture

| Property    | Value                                                        |
|-------------|--------------------------------------------------------------|
| Architecture| x86_64 — 64-bit processor, can also run 32-bit programs      |
| Byte Order  | Little Endian — standard for Intel/AMD CPUs                  |

---

### CPU Details

| Property          | Value                                      |
|-------------------|--------------------------------------------|
| Model             | Intel® Core™ i7-7820HQ @ 2.90GHz          |
| Physical Cores    | 4                                          |
| Threads           | 8 (Hyper-Threading enabled, 2 per core)    |
| Socket            | 1 (single CPU in the system)               |
| CPU Family / Model| 6 / 158 (internal Intel identifiers)       |
| Stepping          | 9 (version of the CPU design)              |

---

### Clock Speed

| Property    | Value   |
|-------------|---------|
| Base Clock  | 2.9 GHz |
| Max Turbo   | 3.9 GHz |
| Min Clock   | 0.8 GHz |

---

### Cache

| Level       | Size               | Scope              |
|-------------|--------------------|--------------------|
| L1d + L1i   | 128 KB each        | Per core (4 cores) |
| L2          | 1 MB               | Per core (4 cores) |
| L3          | 8 MB               | Shared             |

---

### Memory

| Type | Total  |
|------|--------|
| RAM  | 15 GiB |
| Swap | 2.0 GiB|

---

## Files

```
.
├── map_inflation.c       # Main C source
├── run_inflation_benchmark.sh     # Bash script to run all configurations
├── README.md                      # This file
```

After running, each configuration produces an output folder:

```
Inflated_{H}x{W}_Obstacle_{step}/
├── inflation_results_{H}x{W}_step{step}.csv
├── generated.json
└── result.json
```

---

## Requirements

- GCC (any version supporting C99 or later)
- A POSIX system (Linux / macOS) for `clock_gettime` and the bash script

---

## How to Compile Manually

```bash
gcc -O2 -o inflation map_inflation_improved.c -lm
```

To override the default matrix size and obstacle step at compile time:

```bash
gcc -O2 -DH=1000 -DW=1000 -DOBS_STEP=25000 -o inflation map_inflation_improved.c -lm
```

Then run:

```bash
./inflation
```

---

## How to Launch with the Bash Script

The script `run_inflation_benchmark.sh` compiles and runs the benchmark for every combination of matrix size and obstacle step you provide, and organises all outputs into named folders automatically.

### Make the script executable (first time only)

```bash
chmod +x run_inflation_benchmark.sh
```

### Run with default parameters

Defaults are sizes `500 1000 2000` and steps `10000 50000`.

```bash
./run_inflation_benchmark.sh
```

### Run with custom parameters

```bash
./run_inflation_benchmark.sh --sizes "500 1000 2000" --steps "10000 50000 100000"
```

### Arguments

| Argument   | Description                                              | Default          |
|------------|----------------------------------------------------------|------------------|
| `--sizes`  | Space-separated list of square matrix sizes (H = W)      | `"500 1000 2000"` |
| `--steps`  | Space-separated list of obstacle step values             | `"10000 50000"`  |
| `--source` | Path to the C source file                                | `map_inflation_improved.c` |
| `--help`   | Print usage information                                  |                  |

### Example

```bash
./run_inflation_benchmark.sh --sizes "1000 2000" --steps "25000 100000"
```

This produces four output folders:

```
Inflated_1000x1000_Obstacle_25000/
Inflated_1000x1000_Obstacle_100000/
Inflated_2000x2000_Obstacle_25000/
Inflated_2000x2000_Obstacle_100000/
```

Each folder contains the CSV and both JSON files for that configuration.

---

## Constants and Parameters

These control the benchmark behaviour and are defined at the top of `map_inflation_improved.c`.

| Constant          | Default   | Description |
|-------------------|-----------|-------------|
| `H`               | `2000`    | Map height in cells. Overridable with `-DH=` at compile time. |
| `W`               | `2000`    | Map width in cells. Overridable with `-DW=` at compile time. |
| `OBS_STEP`        | `50000`   | Number of obstacles added at each map increment. Overridable with `-DOBS_STEP=`. |
| `KSIZE`           | `3`       | Size of the inflation kernel (3 means a 3×3 kernel). |
| `NUM_MAPS`        | `50`      | Number of maps generated per benchmark run. |
| `NUM_RUNS`        | `5`       | Number of times each map is inflated to compute stable timing statistics. |
| `LETHAL_OBSTACLE` | `254`     | The value written into the map to mark an obstacle cell. |
| `FIRST_OBS`       | `10`      | Number of obstacles in the very first map (Map_1). |

Map `m` (1-indexed) contains `FIRST_OBS + (m-1) * OBS_STEP` obstacles. So with defaults, Map_1 has 10 obstacles and Map_50 has 2,450,010 obstacles.

---

## Inflation Kernel

The 3×3 kernel defines the cost weights applied around each obstacle:

```
 50   80   50
 80  254   80
 50   80   50
```

The centre cell (254) corresponds to the obstacle itself. The adjacent cells (80) represent the immediate danger zone. The diagonal cells (50) represent a lower but nonzero cost. These values are `uint16_t` to avoid overflow when multiplied with `uint8_t` map values (maximum product: 254 × 254 = 64,516, which fits in `uint16_t`).

---

## Code Structure

### `clear_map`

Sets every cell of a map to zero using `memset`. Called at the start of `generate_map` to ensure no leftover data.

---

### `generate_map`

Randomly places `n_obstacles` obstacle cells onto a blank map using the **Fisher-Yates partial shuffle**. 

A flat array of all `H × W` cell indices is built, then the first `n_obstacles` positions are shuffled randomly and used as obstacle positions. This guarantees no duplicate positions and runs in exactly O(n_obstacles) time, regardless of how dense the map is. The obstacle value written is `LETHAL_OBSTACLE` (254). All other cells remain 0.

The seed is fixed (`srand(0)`) so results are fully reproducible across runs.

---

### `mat_mul_3x3`

```c
void mat_mul_3x3(const uint8_t  patch [KSIZE][KSIZE],
                 const uint16_t kernel[KSIZE][KSIZE],
                       uint16_t result[KSIZE][KSIZE])
```

Performs an **element-wise (Hadamard) product** of a 3×3 input patch with the 3×3 inflation kernel. Each output cell is simply `patch[i][j] * kernel[i][j]`.

This is the **exact operation your FPGA hardware accelerates**. It is isolated in its own function so its CPU execution time can be measured cleanly and compared directly against hardware latency. No clamping is applied — output values are left as raw `uint16_t`.

---

### `inflate_from_obstacles_3x3`

```c
int inflate_from_obstacles_3x3(uint8_t  input [H][W],
                                uint16_t output[H][W],
                                double  *mul_time_ms)
```

This is the main inflation function. It runs in three phases:

**Phase 1 — Scan and extract (not timed)**

The entire input map is scanned cell by cell. Every time a cell with value `LETHAL_OBSTACLE` is found, its 3×3 neighbourhood is extracted and stored as an `ObstaclePatch` in a dynamically allocated array. Cells that fall outside the map boundary are treated as 0. This phase is not timed because it represents CPU work that would still happen even with the FPGA present — the CPU must always identify which cells are obstacles and prepare patches before sending them to the hardware.

**Phase 2 — Multiplication (timed)**

A single pair of `clock_gettime` calls wraps a loop that calls `mat_mul_3x3` once for every obstacle found in Phase 1. The timer fires once before the loop starts and once after it ends, so the measured time is the **total cost of all multiplications for the entire map in one shot**. This avoids the per-call timer overhead that would distort results if the clock were called inside the loop. The value stored in `*mul_time_ms` is the number you compare against your FPGA.

**Phase 3 — Write back (not timed)**

The multiplication results are applied to the output map. For each obstacle's 3×3 result patch, each cell is written to the output only if the new value is greater than the current output value (per-cell maximum). This handles the case where two nearby obstacles have overlapping inflation zones — the higher cost wins. No clamping is applied; values remain `uint16_t`. This phase is not timed because it also remains on the CPU in the real system.

The function returns the number of obstacles found, which equals the number of `mat_mul_3x3` calls made.

---

### `elapsed_ms`

A small inline helper that computes the difference between two `struct timespec` values and returns the result in milliseconds as a `double`.

---

### `save_generated_json`

Writes all `NUM_MAPS` input maps to `generated.json` after the benchmark completes. Each map is written in order (Map_1 first, Map_50 last).

---

### `save_results_json`

Writes all `NUM_MAPS` inflated output maps to `result.json` after the benchmark completes. The structure mirrors `generated.json` exactly, but values are `uint16_t` with no clamping.

---

## Output Files

### `inflation_results_{H}x{W}_step{OBS_STEP}.csv`

One row per map. Contains all timing statistics for that map across `NUM_RUNS` repeated runs.

| Column               | Type    | Description |
|----------------------|---------|-------------|
| `map_name`           | string  | Identifier for the map, e.g. `Map_1`, `Map_2`, ..., `Map_50`. |
| `num_obstacles`      | integer | Number of obstacle cells placed in this map. |
| `total_sum_ms`       | float   | Sum of the full `inflate_from_obstacles_3x3` execution time across all `NUM_RUNS` runs, in milliseconds. Useful for throughput calculations. |
| `total_avg_ms`       | float   | Average full execution time per run (`total_sum_ms / NUM_RUNS`). Represents the typical end-to-end cost of one inflation pass. |
| `total_min_ms`       | float   | Fastest full execution time observed across all runs. Closest to the true hardware speed with minimal OS interference. |
| `total_max_ms`       | float   | Slowest full execution time observed. Indicates worst-case OS jitter or cache cold-start effects. |
| `mul_sum_ms`         | float   | Sum of `mat_mul_3x3`-only time across all `NUM_RUNS` runs, in milliseconds. This is the direct equivalent of FPGA total processing time for the same maps. |
| `mul_avg_ms`         | float   | Average multiplication-only time per run (`mul_sum_ms / NUM_RUNS`). The primary metric for CPU vs FPGA comparison. |
| `mul_min_ms`         | float   | Fastest multiplication-only time. Best-case CPU speed for the multiply operation. |
| `mul_max_ms`         | float   | Slowest multiplication-only time. Worst-case CPU speed due to interruptions. |
| `num_multiplications`| integer | Number of `mat_mul_3x3` calls made for this map, equal to the number of obstacles. |

The difference `total_avg_ms - mul_avg_ms` is the irreducible CPU overhead (scanning, patch extraction, write-back) that remains even if the FPGA performs multiplications instantaneously.

---

### `generated.json`

Contains all 50 generated input maps. Structure:

```json
{
  "maps": [
    {
      "id": 1,
      "num_obstacles": 10,
      "data": [
        [0, 0, 254, 0, ...],
        [0, 0, 0,   0, ...],
        ...
      ]
    },
    ...
  ]
}
```

| Field           | Type             | Description |
|-----------------|------------------|-------------|
| `id`            | integer          | Map index, from 1 to `NUM_MAPS` (50). Maps are saved in order. |
| `num_obstacles` | integer          | Number of obstacle cells placed in this map. Equal to `FIRST_OBS + (id-1) * OBS_STEP`. |
| `data`          | 2D array of uint8 | The full H×W map grid. Each row is a JSON array of `W` integers. Values are either `0` (free cell) or `254` (obstacle). |

---

### `result.json`

Contains all 50 inflated output maps. Structure is identical to `generated.json`.

```json
{
  "maps": [
    {
      "id": 1,
      "num_obstacles": 10,
      "data": [
        [0, 0, 64516, 0, ...],
        [0, 0, 0,     0, ...],
        ...
      ]
    },
    ...
  ]
}
```

| Field           | Type              | Description |
|-----------------|-------------------|-------------|
| `id`            | integer           | Map index, from 1 to `NUM_MAPS` (50). Matches the corresponding entry in `generated.json`. |
| `num_obstacles` | integer           | Number of obstacles in this map. Same value as in `generated.json` for the same id. |
| `data`          | 2D array of uint16 | The full H×W inflated map grid. Each value is the result of the element-wise multiplication of the input patch with the kernel, kept as raw `uint16_t` with no clamping. Maximum possible value is 254 × 254 = 64,516. Non-inflated cells are 0. When two obstacles overlap, the higher value is kept (per-cell maximum). |

---

## CPU vs FPGA Comparison Guide

To compare your FPGA against the CPU baseline, use the following columns from the CSV:

- **`mul_min_ms`** — the best CPU time for all multiplications on a given map. Compare this against your FPGA latency for the same number of operations (`num_multiplications`).
- **`mul_avg_ms`** — the typical CPU time. Useful for real-world throughput comparison.
- **`num_multiplications`** — tells you exactly how many 3×3 operations were performed. Use this to compute operations per second: `num_multiplications / mul_min_ms * 1000`.

Even if your FPGA performs all multiplications in zero time, the total pipeline will still take at least `total_avg_ms - mul_avg_ms` milliseconds per map, because that is the time spent on scanning, patch extraction, and write-back — work that stays on the CPU regardless.

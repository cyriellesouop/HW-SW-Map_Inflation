# FPGA Inflation Latency Analysis

## Overview

This toolset estimates and records the number of clock cycles required by an
FPGA hardware accelerator to perform costmap inflation on a set of obstacle
cells. It consists of two components:

- `fpga_cycles.c` — a C program that computes the cycle breakdown for each
  pipeline stage given a set of hardware parameters and a list of obstacle
  counts.
- `generate_latency_excel.py` — a Python script that drives the C binary,
  iterates over a list of obstacle counts, and writes all results into a
  formatted Excel workbook.

---

## Files

```
.
├── fpga_cycles.c               # C source — cycle computation engine
├── generate_latency_excel.py   # Python script — runs C binary, writes Excel
└── README.md                   # This file
```

---

## How to Compile

```bash
gcc -O2 -o fpga_cycles fpga_cycles.c -lm
```

---

## How to Run

```bash
python generate_latency_excel.py \
    --binary       ./fpga_cycles \
    --cpu_bram     3             \
    --dma_ip       4             \
    --latency      25            \
    --kernel       3             \
    --burst_length 16            \
    --obstacles    100 500 1000 5000 9810
```

This produces an Excel workbook named following the pattern:

```
latency_results_k{kernel}_burst{burst_length}_obs{obstacles...}.xlsx
```

For example:

```
latency_results_k3_burst16_obs100_500_1000_5000_9810.xlsx
```

---

## Python Script Parameters

| Parameter        | Type    | Required | Default          | Description |
|------------------|---------|----------|------------------|-------------|
| `--binary`       | string  | No       | `./fpga_cycles`  | Path to the compiled `fpga_cycles` binary. |
| `--cpu_bram`     | integer | Yes      | —                | Number of clock cycles the MicroBlaze CPU takes to write a single 32-bit word into the BRAM. This reflects the cost of one AXI bus transaction initiated by the soft processor. |
| `--dma_ip`       | integer | Yes      | —                | Number of clock cycles between the DMA dispatching the first data word and that word arriving at the input interface of the IP accelerator. This is a fixed propagation latency of the AXI interconnect. |
| `--latency`      | integer | Yes      | —                | Pipeline latency of the systolic array in clock cycles. Defined as the number of cycles between the first input pixel entering the systolic array and the last output value of the **first** obstacle's inflation result being produced. |
| `--kernel`       | integer | No       | `3`              | Side length K of the square inflation kernel. For a 3×3 kernel, K=3. Each obstacle requires K² input pixel values. |
| `--burst_length` | integer | No       | `16`             | Number of beats in a single AXI DMA burst transaction. Each beat transfers one 32-bit word. A longer burst length reduces the per-word AXI overhead (address phase + handshake) and therefore reduces total DMA cycles. |
| `--obstacles`    | integer | Yes      | —                | Space-separated list of obstacle counts to evaluate. The script runs the C binary once with all values and produces one Excel detail sheet per obstacle count. |

---

## Excel Workbook Structure

The output workbook contains:

- A **Summary** sheet listing all obstacle counts in a single comparison table.
- One **detail sheet per obstacle count**, named `latency_result_{K}_{N}`,
  showing the full system parameter block and pipeline stage breakdown for
  that specific configuration.

---

## Excel Column Definitions

These columns appear in the Summary sheet and in the data table of each
detail sheet.

| Column                 | Unit   | Description |
|------------------------|--------|-------------|
| **Kernel Size**        | —      | Side length K of the inflation kernel. Determines how many values must be sent per obstacle (K²). |
| **Burst Length**       | beats  | Number of 32-bit words transferred per DMA burst transaction. Set by the `--burst_length` argument. |
| **Obstacles**          | count  | Number of occupied cells detected in the occupancy map for this row. |
| **Total Values**       | values | Total number of 8-bit pixel values that must be sent to the accelerator. Computed as `Obstacles × K²`. For K=3 and 9,810 obstacles this is 88,290 values. |
| **AXI Transfers**      | beats  | Number of 32-bit AXI Stream beats required to carry all pixel values. Since four 8-bit values are packed into each 32-bit beat, this is `⌈Total Values / 4⌉`. |
| **Full Bursts**        | bursts | Number of complete DMA bursts of exactly `Burst Length` beats. Computed as `⌊AXI Transfers / Burst Length⌋`. |
| **Partial Burst Words**| beats  | Number of beats in the final incomplete burst, if `AXI Transfers` is not exactly divisible by `Burst Length`. Zero means all bursts are full. |
| **DMA Cycles**         | cycles | Total clock cycles consumed by the DMA transfer stage. Each full burst costs `Burst Length + 2` cycles (the +2 accounts for the AXI address phase and ready/valid handshake). The partial burst, if present, costs `Partial Burst Words + 2` cycles. |
| **DMA→IP Cycles**      | cycles | Fixed latency in clock cycles between the DMA dispatching the first beat and that beat reaching the accelerator input interface. Set by the `--dma_ip` argument. This cost is paid once per map regardless of obstacle count. |
| **Systolic Cycles**    | cycles | Total cycles consumed by the fully pipelined systolic array to process all obstacles. Because the pipeline is full after the first latency period, this is `Latency + (Obstacles − 1)`, not `Latency × Obstacles`. |
| **Total Cycles**       | cycles | End-to-end hardware cycle count: `DMA Cycles + DMA→IP Cycles + Systolic Cycles`. This is the number you divide by the operating frequency to obtain the hardware execution time. |

---

## Pipeline Diagram

```
 ┌─────────────────────────────────────────────────────────────┐
 │  Stage 1          Stage 2         Stage 3                   │
 │                                                             │
 │  DMA Burst    →   DMA → IP    →   Systolic Array           │
 │  (N transfers)    (fixed, 1x)     (latency + N_obs - 1)    │
 │                                                             │
 │  Cycles:          Cycles:         Cycles:                   │
 │  DMA Cycles       DMA→IP Cycles   Systolic Cycles          │
 └─────────────────────────────────────────────────────────────┘
  ◄──────────────── Total Cycles ───────────────────────────►
```

---

## Worked Example

```
Parameters:
  --cpu_bram 3  --dma_ip 4  --latency 25  --kernel 3
  --burst_length 16  --obstacles 9810
```

| Step | Calculation | Result |
|------|-------------|--------|
| Total values | 9,810 × 9 | 88,290 |
| AXI transfers | ⌈88,290 / 4⌉ | 22,073 |
| Full bursts | ⌊22,073 / 16⌋ | 1,379 |
| Partial burst words | 22,073 − 1,379 × 16 | 9 |
| DMA cycles | 1,379 × 18 + (9 + 2) | 24,833 |
| DMA→IP cycles | (fixed) | 4 |
| Systolic cycles | 25 + (9,810 − 1) | 9,834 |
| **Total cycles** | 24,833 + 4 + 9,834 | **34,671** |

---

## Requirements

- GCC (C99 or later)
- Python 3.7+
- `openpyxl` Python package

```bash
pip install openpyxl
```

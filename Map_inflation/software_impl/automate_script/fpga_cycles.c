#include <stdio.h>
#include <stdlib.h>
#include <math.h>

/* ---------------------------------------------------------
   Constants
--------------------------------------------------------- */
#define KERNEL_SIZE     9       /* 3x3 kernel -> 9 values per obstacle   */
#define AXI_DATA_BITS   32      /* AXI stream interface data width (bits) */
#define VALUE_BITS      8       /* each map cell value is 8 bits          */
#define VALUES_PER_TRANSFER (AXI_DATA_BITS / VALUE_BITS)  /* = 4          */

/* ---------------------------------------------------------
   compute_num_transfers

   Computes the number of AXI stream transfers needed to
   send all patch data for a complete map inflation.

   For N obstacles:
     - Each obstacle requires 9 values (3x3 patch)
     - Total values = N * 9
     - Each AXI transfer packs 4 values (32-bit / 8-bit)
     - Number of transfers = ceil(total_values / 4)

   Arguments:
     n_obstacles  : number of obstacle cells in the map

   Returns:
     total number of AXI stream transfers required
--------------------------------------------------------- */
int compute_num_transfers(int n_obstacles)
{
    int total_values  = n_obstacles * KERNEL_SIZE;
    int num_transfers = (total_values + VALUES_PER_TRANSFER - 1)
                        / VALUES_PER_TRANSFER;   /* integer ceil division */

    printf("--- Transfer Computation ---\n");
    printf("  Obstacles              : %d\n",   n_obstacles);
    printf("  Values per obstacle    : %d  (3x3 patch)\n", KERNEL_SIZE);
    printf("  Total values           : %d\n",   total_values);
    printf("  Values per transfer    : %d  (%d-bit AXI / %d-bit value)\n",
           VALUES_PER_TRANSFER, AXI_DATA_BITS, VALUE_BITS);
    printf("  Total transfers needed : %d\n\n", num_transfers);

    return num_transfers;
}

/* ---------------------------------------------------------
   compute_total_hardware_cycles

   Computes the total number of clock cycles the FPGA
   hardware design takes to complete inflation on all
   obstacles of a given map.

   The pipeline stages are:

     Stage 1 — CPU writes all data to BRAM:
       num_transfers * cycles_cpu_to_bram

     Stage 2 — DMA sends the first data to the IP input:
       cycles_dma_to_ip
       (one-time latency before streaming begins)

     Stage 3 — First data travels from IP input to the
               systolic array input:
       cycles_ip_to_systolic

     Stage 4 — Systolic array processes all data
               (from first input to last output):
       cycles_systolic_latency

   Total = Stage1 + Stage2 + Stage3 + Stage4

   Arguments:
     cycles_cpu_to_bram    : clock cycles to transfer one
                             32-bit word from MicroBlaze to BRAM
     num_transfers         : total AXI stream transfers
                             (computed by compute_num_transfers)
     cycles_dma_to_ip      : clock cycles for the first data
                             to travel from DMA to IP input
     cycles_ip_to_systolic : clock cycles for the first data
                             to travel from IP input to the
                             systolic array input
     cycles_systolic_latency: clock cycles from the first data
                              entering the systolic array to
                              the last result coming out

   Returns:
     total clock cycles for the full hardware inflation
--------------------------------------------------------- */
long long compute_total_hardware_cycles(int cycles_cpu_to_bram,
                                        int num_transfers,
                                        int cycles_dma_to_ip,
                                        int cycles_ip_to_systolic,
                                        int cycles_systolic_latency)
{
    long long stage1 = (long long)num_transfers * cycles_cpu_to_bram;
    long long stage2 = cycles_dma_to_ip;
    long long stage3 = cycles_ip_to_systolic;
    long long stage4 = cycles_systolic_latency;

    long long total  = stage1 + stage2 + stage3 + stage4;

    printf("--- Hardware Cycle Breakdown ---\n");
    printf("  Stage 1 | CPU -> BRAM         : %d transfers x %d cycles = %lld cycles\n",
           num_transfers, cycles_cpu_to_bram, stage1);
    printf("  Stage 2 | DMA -> IP input     : %lld cycles\n", stage2);
    printf("  Stage 3 | IP input -> Systolic: %lld cycles\n", stage3);
    printf("  Stage 4 | Systolic latency    : %lld cycles\n", stage4);
    printf("  -------------------------------------------------\n");
    printf("  Total hardware cycles         : %lld cycles\n\n", total);

    return total;
}

/* ---------------------------------------------------------
   MAIN

   Arguments (all positional, in order):
     1. cycles_cpu_to_bram     (int)
     2. n_obstacles             (int)
     3. cycles_dma_to_ip        (int)
     4. cycles_ip_to_systolic   (int)
     5. cycles_systolic_latency (int)

   Example:
     ./fpga_cycles 10 100 5 3 120
--------------------------------------------------------- */
int main(int argc, char *argv[])
{
    if (argc != 6)
    {
        fprintf(stderr,
            "Usage: %s <cycles_cpu_to_bram> <n_obstacles> "
            "<cycles_dma_to_ip> <cycles_ip_to_systolic> "
            "<cycles_systolic_latency>\n\n"
            "  cycles_cpu_to_bram     : clock cycles per transfer "
                                       "from MicroBlaze to BRAM\n"
            "  n_obstacles            : number of obstacles in the map\n"
            "  cycles_dma_to_ip       : clock cycles for first data "
                                       "from DMA to IP input\n"
            "  cycles_ip_to_systolic  : clock cycles for first data "
                                       "from IP input to systolic array\n"
            "  cycles_systolic_latency: clock cycles from first systolic "
                                       "input to last systolic output\n\n"
            "Example:\n"
            "  %s 10 100 5 3 120\n",
            argv[0], argv[0]);
        return 1;
    }

    /* --- parse arguments --- */
    int cycles_cpu_to_bram     = atoi(argv[1]);
    int n_obstacles             = atoi(argv[2]);
    int cycles_dma_to_ip        = atoi(argv[3]);
    int cycles_ip_to_systolic   = atoi(argv[4]);
    int cycles_systolic_latency = atoi(argv[5]);

    /* --- validate --- */
    if (cycles_cpu_to_bram <= 0 || n_obstacles <= 0 ||
        cycles_dma_to_ip <= 0   || cycles_ip_to_systolic <= 0 ||
        cycles_systolic_latency <= 0)
    {
        fprintf(stderr, "Error: all arguments must be positive integers.\n");
        return 1;
    }

    printf("=================================================\n");
    printf("  FPGA Inflation Hardware Cycle Estimator\n");
    printf("=================================================\n\n");

    /* --- Step 1: compute the number of AXI transfers --- */
    int num_transfers = compute_num_transfers(n_obstacles);

    /* --- Step 2: compute total hardware cycles --- */
    long long total_cycles = compute_total_hardware_cycles(
                                cycles_cpu_to_bram,
                                num_transfers,
                                cycles_dma_to_ip,
                                cycles_ip_to_systolic,
                                cycles_systolic_latency);

    printf("=================================================\n");
    printf("  Result: %lld clock cycles\n", total_cycles);
    printf("=================================================\n");

    return 0;
}

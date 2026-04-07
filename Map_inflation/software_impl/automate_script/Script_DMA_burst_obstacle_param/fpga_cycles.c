#include <stdio.h>
#include <stdlib.h>
#include <math.h>

/* ---------------------------------------------------------
   Constants
--------------------------------------------------------- */
#define AXI_DATA_BITS          32
#define VALUE_BITS              8
#define VALUES_PER_TRANSFER    (AXI_DATA_BITS / VALUE_BITS)   /* = 4 */
#define DMA_BURST_OVERHEAD      2    /* AXI address phase + handshake */

/* ---------------------------------------------------------
   compute_num_transfers
   Returns the number of AXI beats needed to send all patch
   data for n_obstacles obstacles with a kernel of size K.
--------------------------------------------------------- */
int compute_num_transfers(int n_obstacles, int kernel_size)
{
    int total_values  = n_obstacles * kernel_size * kernel_size;
    int num_transfers = (total_values + VALUES_PER_TRANSFER - 1)
                        / VALUES_PER_TRANSFER;
    return num_transfers;
}

/* ---------------------------------------------------------
   compute_dma_cycles
   Returns total DMA clock cycles for num_transfers beats
   using the provided burst_length.
--------------------------------------------------------- */
long long compute_dma_cycles(int num_transfers, int burst_length)
{
    int n_full    = num_transfers / burst_length;
    int n_partial = num_transfers % burst_length;

    long long cycles = (long long)n_full * (burst_length + DMA_BURST_OVERHEAD);
    if (n_partial > 0)
        cycles += n_partial + DMA_BURST_OVERHEAD;

    return cycles;
}

/* ---------------------------------------------------------
   compute_systolic_cycles
   Fully pipelined: latency + (n_obstacles - 1)
--------------------------------------------------------- */
long long compute_systolic_cycles(int n_obstacles, int systolic_latency)
{
    if (n_obstacles <= 0) return 0;
    return systolic_latency + (n_obstacles - 1);
}

/* ---------------------------------------------------------
   MAIN

   Usage:
     ./fpga_cycles <cycles_cpu_to_bram> <cycles_dma_to_ip>
                  <cycles_ip_to_systolic> <systolic_latency>
                  <kernel_size> <burst_length>
                  <obs1> <obs2> ... <obsN>

   Example:
     ./fpga_cycles 3 26 5 30 3 16 100 500 1000 5000 9810
--------------------------------------------------------- */
int main(int argc, char *argv[])
{
    if (argc < 8)
    {
        fprintf(stderr,
            "Usage: %s <cycles_cpu_to_bram> <cycles_dma_to_ip> "
            "<cycles_ip_to_systolic> <systolic_latency> "
            "<kernel_size> <burst_length> "
            "<obs1> [obs2 ... obsN]\n\n"
            "  cycles_cpu_to_bram    : cycles per CPU->BRAM word write\n"
            "  cycles_dma_to_ip      : cycles from DMA to IP input interface\n"
            "  cycles_ip_to_systolic : cycles from IP input ports to systolic array input\n"
            "  systolic_latency      : cycles from first systolic input to last output\n"
            "  kernel_size           : side length K of the square kernel\n"
            "  burst_length          : DMA burst length in beats\n"
            "  obs1 ...              : list of obstacle counts to evaluate\n\n"
            "Example:\n"
            "  %s 3 26 5 30 3 16 100 500 1000 5000 9810\n",
            argv[0], argv[0]);
        return 1;
    }

    /* --- parse fixed arguments --- */
    int cycles_cpu_to_bram    = atoi(argv[1]);
    int cycles_dma_to_ip      = atoi(argv[2]);
    int cycles_ip_to_systolic = atoi(argv[3]);
    int systolic_latency      = atoi(argv[4]);
    int kernel_size           = atoi(argv[5]);
    int burst_length          = atoi(argv[6]);

    /* --- validate --- */
    if (cycles_cpu_to_bram <= 0    || cycles_dma_to_ip <= 0 ||
        cycles_ip_to_systolic <= 0 || systolic_latency <= 0  ||
        kernel_size <= 0           || burst_length <= 0)
    {
        fprintf(stderr, "Error: all fixed arguments must be positive integers.\n");
        return 1;
    }

    int n_obs_list = argc - 7;   /* number of obstacle counts provided */

    /* --- CSV header --- */
    printf("kernel_size,"
           "burst_length,"
           "n_obstacles,"
           "n_values,"
           "n_transfers,"
           "n_full_bursts,"
           "n_partial_burst_words,"
           "cycles_dma,"
           "cycles_dma_to_ip,"
           "cycles_ip_to_systolic,"
           "cycles_systolic,"
           "cycles_total\n");

    /* --- iterate over obstacle list --- */
    for (int i = 0; i < n_obs_list; i++)
    {
        int n_obs = atoi(argv[7 + i]);
        if (n_obs <= 0)
        {
            fprintf(stderr, "Warning: skipping invalid obstacle count '%s'\n",
                    argv[7 + i]);
            continue;
        }

        int       n_values    = n_obs * kernel_size * kernel_size;
        int       n_transfers = compute_num_transfers(n_obs, kernel_size);
        int       n_full      = n_transfers / burst_length;
        int       n_partial   = n_transfers % burst_length;
        long long c_dma       = compute_dma_cycles(n_transfers, burst_length);
        long long c_systolic  = compute_systolic_cycles(n_obs, systolic_latency);
        long long c_total     = c_dma
                              + cycles_dma_to_ip
                              + cycles_ip_to_systolic
                              + c_systolic;

        printf("%d,%d,%d,%d,%d,%d,%d,%lld,%d,%d,%lld,%lld\n",
               kernel_size,
               burst_length,
               n_obs,
               n_values,
               n_transfers,
               n_full,
               n_partial,
               c_dma,
               cycles_dma_to_ip,
               cycles_ip_to_systolic,
               c_systolic,
               c_total);
    }

    return 0;
}

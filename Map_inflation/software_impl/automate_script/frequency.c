#include <stdio.h>
#include <stdlib.h>

/* ---------------------------------------------------------
   compute_required_frequency

   Derives the minimum clock frequency (in Hz) at which the
   FPGA design must run to complete the inflation faster than
   the software implementation.

   Constraint:
       hardware_time < software_time
       total_cycles / frequency < software_time_s
       frequency > total_cycles / software_time_s

   Arguments:
     total_cycles      : total clock cycles of the hardware design
     software_time_ms  : software execution time in milliseconds

   Returns:
     minimum frequency in Hz to beat the software
--------------------------------------------------------- */
double compute_required_frequency(long long total_cycles,
                                  double    software_time_ms)
{
    double software_time_s = software_time_ms / 1000.0;
    double min_freq_hz     = (double)total_cycles / software_time_s;
    return min_freq_hz;
}

/* ---------------------------------------------------------
   compute_hardware_time_ms

   Computes the actual hardware execution time in milliseconds
   given a number of cycles and a clock frequency.

   Arguments:
     total_cycles : total clock cycles
     freq_hz      : clock frequency in Hz

   Returns:
     execution time in milliseconds
--------------------------------------------------------- */
double compute_hardware_time_ms(long long total_cycles, double freq_hz)
{
    return ((double)total_cycles / freq_hz) * 1000.0;
}

/* ---------------------------------------------------------
   MAIN
--------------------------------------------------------- */
int main(void)
{
    /* --------------------------------------------------
       Known values from the hardware implementation
    -------------------------------------------------- */
    int  n_obstacles            = 9810;
    long long cycles_cpu_bram   = 66219;  /* MicroBlaze -> BRAM          */
    long long cycles_dma_to_ip  = 26;     /* DMA -> IP accelerator input */
    long long cycles_systolic   = 30;     /* IP input -> last output     */
    long long total_cycles      = cycles_cpu_bram + cycles_dma_to_ip + cycles_systolic;

    double software_time_ms     = 0.187476;  /* software inflation time  */
    double microblaze_freq_hz   = 100e6;     /* MicroBlaze at 100 MHz    */

    /* --------------------------------------------------
       Print the known inputs
    -------------------------------------------------- */
    printf("=================================================\n");
    printf("  FPGA vs Software Frequency Analysis\n");
    printf("=================================================\n\n");

    printf("--- Inputs ---\n");
    printf("  Obstacles                  : %d\n",    n_obstacles);
    printf("  Software time              : %.6f ms\n", software_time_ms);
    printf("  MicroBlaze frequency       : %.0f MHz\n", microblaze_freq_hz / 1e6);
    printf("\n");

    printf("--- Hardware Cycle Breakdown ---\n");
    printf("  CPU -> BRAM (MicroBlaze)   : %lld cycles\n", cycles_cpu_bram);
    printf("  DMA -> IP input            : %lld cycles\n", cycles_dma_to_ip);
    printf("  IP input -> last output    : %lld cycles\n", cycles_systolic);
    printf("  -----------------------------------------\n");
    printf("  Total hardware cycles      : %lld cycles\n\n", total_cycles);

    /* --------------------------------------------------
       Compute the minimum frequency required to beat
       the software implementation
    -------------------------------------------------- */
    double min_freq_hz  = compute_required_frequency(total_cycles, software_time_ms);
    double min_freq_mhz = min_freq_hz / 1e6;

    printf("--- Frequency Required to Beat Software ---\n");
    printf("  Minimum frequency needed   : %.4f MHz\n\n", min_freq_mhz);

    /* --------------------------------------------------
       Show how fast the hardware actually runs at the
       MicroBlaze frequency (100 MHz) as a reference
    -------------------------------------------------- */
    double hw_time_at_100mhz = compute_hardware_time_ms(total_cycles,
                                                         microblaze_freq_hz);

    printf("--- Reference: Hardware at 100 MHz ---\n");
    printf("  Hardware time at 100 MHz   : %.6f ms\n", hw_time_at_100mhz);
    printf("  Software time              : %.6f ms\n", software_time_ms);
    printf("  Hardware faster?           : %s\n\n",
           hw_time_at_100mhz < software_time_ms ? "YES" : "NO");

    /* --------------------------------------------------
       Show what happens at the minimum required frequency
    -------------------------------------------------- */
    double hw_time_at_min = compute_hardware_time_ms(total_cycles, min_freq_hz);

    printf("--- Verification at Minimum Required Frequency ---\n");
    printf("  Frequency                  : %.4f MHz\n",   min_freq_mhz);
    printf("  Hardware time              : %.6f ms\n",    hw_time_at_min);
    printf("  Software time              : %.6f ms\n",    software_time_ms);
    printf("  Hardware faster?           : %s\n\n",
           hw_time_at_min < software_time_ms ? "YES" : "EQUAL (need strictly higher)");

    /* --------------------------------------------------
       Suggest the nearest standard FPGA frequency above
       the minimum (round up to next 50 MHz boundary)
    -------------------------------------------------- */
    double step_mhz       = 50.0;
    double suggested_mhz  = (double)((int)(min_freq_mhz / step_mhz) + 1) * step_mhz;
    double hw_at_suggested = compute_hardware_time_ms(total_cycles,
                                                       suggested_mhz * 1e6);

    printf("--- Suggested Practical Frequency ---\n");
    printf("  Next standard frequency    : %.0f MHz\n",  suggested_mhz);
    printf("  Hardware time at %.0f MHz  : %.6f ms\n",  suggested_mhz, hw_at_suggested);
    printf("  Speedup over software      : %.2fx\n",
           software_time_ms / hw_at_suggested);
    printf("\n");
    printf("=================================================\n");
    printf("  Conclusion: the design must run above %.4f MHz\n", min_freq_mhz);
    printf("  Recommended target         : %.0f MHz\n", suggested_mhz);
    printf("=================================================\n");

    return 0;
}

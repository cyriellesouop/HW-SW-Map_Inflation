gcc -O2 -o fpga_cycles fpga_cycles.c -lm

# Example: 10 cycles/transfer, 100 obstacles,
#          5 cycles DMA->IP, 3 cycles IP->systolic, 120 cycles systolic latency
./fpga_cycles 3 9810 4 5 25


#3 9810 26 5 25
#**Example output:**

#kernel 3x3
#Stage 3 | IP input -> Systolic: 3 cycles
#Stage 4 | Systolic latency    : 25 cycles

#kernel 8x8
#Stage 3 | IP input -> Systolic: 3 cycles
#Stage 4 | Systolic latency    : 25 cycles


#Stage 1 | CPU -> BRAM         : 225 transfers x 10 cycles = 2250 cycles
#Stage 2 | DMA -> IP input     : 5 cycles
#Stage 3 | IP input -> Systolic: 3 cycles
#Stage 4 | Systolic latency    : 120 cycles
#Total hardware cycles         : 2378 cycles

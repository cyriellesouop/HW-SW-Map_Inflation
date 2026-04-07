#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <time.h>

/* ---------------------------------------------------------
   Map dimensions and kernel size — override at compile time:
       gcc -DH=512 -DW=512 -DKSIZE=7 ...
--------------------------------------------------------- */
#ifndef H
#define H 500
#endif
#ifndef W
#define W 500
#endif
#ifndef KSIZE
#define KSIZE 9
#endif
#ifndef OBS_STEP
#define OBS_STEP 200        /* obstacle increment per map */
#endif

#define NUM_MAPS        50
#define NUM_RUNS        3   /* repeat each run, report average */
#define LETHAL_OBSTACLE 254

/* ---------------------------------------------------------
   Operation counter struct — tracks every arithmetic and
   logic operation performed by each algorithm.

   RASTER-SCAN (binary dilation):
     - comparisons : each kernel cell checks input == LETHAL
     - additions   : index arithmetic (y+di, x+dj per cell)
     - multiplications : 0  (no multiply in binary dilation)

   OBSTACLE-DRIVEN (weighted convolution):
     - multiplications : patch[i][j] * kernel[i][j]
     - additions       : index arithmetic + result accumulation
     - comparisons     : input[y][x] == LETHAL (obstacle scan)
                       + output max comparison per write-back
--------------------------------------------------------- */
typedef struct {
    long long multiplications;
    long long additions;
    long long comparisons;
} OpCount;

/* ---------------------------------------------------------
   Weighted 9x9 inflation kernel (cost-gradient)
   Override KSIZE at compile time for 3, 5, 7, 9, 11 ...
   We define up to 11x11 and select at runtime via ksize arg.
--------------------------------------------------------- */
static const uint16_t KERNEL_9x9[9][9] = {
 { 50,  80,  50},
 { 80, 254,  80},
 { 50,  80,  50}
};

/* flat kernel pointer — set in main() based on KSIZE */
static uint16_t g_kernel[KSIZE * KSIZE];

/* ---------------------------------------------------------
   Elapsed time helper
--------------------------------------------------------- */
static inline double elapsed_ms(struct timespec a, struct timespec b)
{
    return (b.tv_sec  - a.tv_sec ) * 1e3
         + (b.tv_nsec - a.tv_nsec) / 1e6;
}

/* ---------------------------------------------------------
   Map generation — Fisher-Yates random placement
--------------------------------------------------------- */
void generate_map(uint8_t *map, int n_obstacles)
{
    int total = H * W;
    if (n_obstacles > total) n_obstacles = total;
    memset(map, 0, total * sizeof(uint8_t));

    int *cells = malloc(total * sizeof(int));
    if (!cells) { perror("malloc"); exit(1); }
    for (int i = 0; i < total; i++) cells[i] = i;

    for (int i = 0; i < n_obstacles; i++) {
        int j    = i + rand() % (total - i);
        int tmp  = cells[i]; cells[i] = cells[j]; cells[j] = tmp;
        map[cells[i]] = LETHAL_OBSTACLE;
    }
    free(cells);
}

/* ===========================================================
   ALGORITHM 1 — BINARY MORPHOLOGICAL DILATION (RASTER-SCAN)
   -----------------------------------------------------------
   Processes EVERY cell of the map regardless of occupancy.
   For each output cell (y,x), slides a flat structuring
   element and checks whether any neighbour is an obstacle.

   Output: binary map (0 or LETHAL_OBSTACLE).

   Operation counts:
     Comparisons    = H * W * KSIZE * KSIZE
                      (one per kernel cell: input == LETHAL?)
                    + H * W
                      (one per output cell: hit ? LETHAL : 0)
     Additions      = H * W * KSIZE * KSIZE * 2
                      (ny = y + di,  nx = x + dj  per cell)
     Multiplications = 0   (no multiply in flat dilation)

   NOTE: early-exit (!hit) can reduce comparisons in practice
         but the WORST CASE (theoretical) is the full count.
=========================================================== */
void algo1_binary_raster(const uint8_t *input,
                               uint8_t *output,
                               OpCount *ops,
                               double  *time_ms)
{
    int half = KSIZE / 2;
    memset(output, 0, H * W * sizeof(uint8_t));
    memset(ops,    0, sizeof(OpCount));

    struct timespec t0, t1;
    clock_gettime(CLOCK_MONOTONIC, &t0);

    for (int y = 0; y < H; y++)
    {
        for (int x = 0; x < W; x++)
        {
            uint8_t hit = 0;

            for (int di = -half; di <= half; di++)
            {
                int ny = y + di;
                ops->additions++;           /* ny = y + di            */

                for (int dj = -half; dj <= half; dj++)
                {
                    int nx = x + dj;
                    ops->additions++;       /* nx = x + dj            */
                    ops->comparisons++;     /* bounds check: ny, nx    */

                    if (ny < 0 || ny >= H || nx < 0 || nx >= W)
                        continue;

                    ops->comparisons++;     /* input[ny][nx]==LETHAL ? */
                    if (input[ny * W + nx] == LETHAL_OBSTACLE)
                        hit = 1;
                }
            }

            ops->comparisons++;             /* hit ? LETHAL : 0        */
            output[y * W + x] = hit ? LETHAL_OBSTACLE : 0;
        }
    }

    clock_gettime(CLOCK_MONOTONIC, &t1);
    *time_ms = elapsed_ms(t0, t1);
}

/* ===========================================================
   ALGORITHM 2 — WEIGHTED CONVOLUTION (OBSTACLE-DRIVEN)
   -----------------------------------------------------------
   Phase 1 (NOT timed, NOT counted): scan map once to collect
            obstacle positions.
   Phase 2 (TIMED + COUNTED): for each obstacle, multiply its
            neighbourhood patch against the cost kernel and
            write back the per-cell maximum.

   Output: uint16_t cost map.

   Operation counts:
     Phase 1 (scan):
       Comparisons    = H * W
                        (one per cell: input == LETHAL?)

     Phase 2 (convolution per obstacle):
       Multiplications = N_obs * KSIZE * KSIZE
       Additions       = N_obs * KSIZE * KSIZE * 2
                         (index: ny = y + di, nx = x + dj)
       Comparisons     = N_obs * KSIZE * KSIZE * 2
                         (bounds check + max comparison)
=========================================================== */
typedef struct { int y, x; } Pos;

int algo2_weighted_obstacle(const uint8_t  *input,
                                  uint16_t *output,
                                  OpCount  *ops,
                                  double   *time_ms)
{
    int half = KSIZE / 2;
    memset(output, 0, H * W * sizeof(uint16_t));
    memset(ops,    0, sizeof(OpCount));

    /* -------------------------------------------------------
       Phase 1 — scan & collect obstacle positions (NOT timed)
       Counts comparisons only (no arithmetic kernel work here)
    ------------------------------------------------------- */
    Pos *obstacles = malloc(H * W * sizeof(Pos));
    if (!obstacles) { perror("malloc"); exit(1); }

    int n_obs = 0;
    for (int y = 0; y < H; y++) {
        for (int x = 0; x < W; x++) {
            ops->comparisons++;             /* input == LETHAL ?       */
            if (input[y * W + x] == LETHAL_OBSTACLE) {
                obstacles[n_obs].y = y;
                obstacles[n_obs].x = x;
                n_obs++;
            }
        }
    }

    /* -------------------------------------------------------
       Phase 2 — weighted convolution per obstacle (TIMED)
    ------------------------------------------------------- */
    struct timespec t0, t1;
    clock_gettime(CLOCK_MONOTONIC, &t0);

    for (int k = 0; k < n_obs; k++)
    {
        int oy = obstacles[k].y;
        int ox = obstacles[k].x;

        for (int di = 0; di < KSIZE; di++)
        {
            int ny = oy + di - half;
            ops->additions++;               /* ny = oy + di - half     */

            for (int dj = 0; dj < KSIZE; dj++)
            {
                int nx = ox + dj - half;
                ops->additions++;           /* nx = ox + dj - half     */
                ops->comparisons++;         /* bounds check            */

                if (ny < 0 || ny >= H || nx < 0 || nx >= W)
                    continue;

                /* Hadamard product: patch value * kernel weight */
                uint16_t val = (uint16_t)input[ny * W + nx]
                               * g_kernel[di * KSIZE + dj];
                ops->multiplications++;     /* the core multiply       */

                ops->comparisons++;         /* val > output[ny][nx] ?  */
                if (val > output[ny * W + nx])
                    output[ny * W + nx] = val;
            }
        }
    }

    clock_gettime(CLOCK_MONOTONIC, &t1);
    *time_ms = elapsed_ms(t0, t1);

    free(obstacles);
    return n_obs;
}

/* ---------------------------------------------------------
   Theoretical operation counts (analytical formulas)
   Use these to cross-check the empirical counters.
--------------------------------------------------------- */
void print_theoretical(int n_obs, double density_pct)
{
    long long map_cells  = (long long)H * W;
    long long k2         = (long long)KSIZE * KSIZE;

    printf("\n  -- Theoretical (worst-case, no bounds clipping) --\n");
    printf("  ALGO 1 (Raster-Scan Binary):\n");
    printf("    Multiplications : 0\n");
    printf("    Additions       : %lld   (H*W*k*k*2 = %lld*%lld*2)\n",
           map_cells * k2 * 2, map_cells, k2);
    printf("    Comparisons     : %lld   (H*W*k*k + H*W = %lld*%lld + %lld)\n",
           map_cells * k2 + map_cells, map_cells, k2, map_cells);

    printf("  ALGO 2 (Obstacle-Driven Weighted):\n");
    printf("    Multiplications : %lld   (N_obs*k*k = %d*%lld)\n",
           (long long)n_obs * k2, n_obs, k2);
    printf("    Additions       : %lld   (N_obs*k*k*2 = %d*%lld*2)\n",
           (long long)n_obs * k2 * 2, n_obs, k2);
    printf("    Comparisons     : %lld   (H*W scan + N_obs*k*k*2)\n",
           map_cells + (long long)n_obs * k2 * 2);
    printf("    Density used    : %.2f%%  (%d obstacles / %lld cells)\n",
           density_pct, n_obs, map_cells);
}

/* ---------------------------------------------------------
   CSV header and row writers
--------------------------------------------------------- */
void write_csv_header(FILE *f)
{
    fprintf(f,
        "map_id,"
        "H,W,ksize,"
        "num_obstacles,obstacle_density_pct,"

        /* Algorithm 1 */
        "a1_time_ms,"
        "a1_multiplications,"
        "a1_additions,"
        "a1_comparisons,"

        /* Algorithm 2 */
        "a2_time_ms,"
        "a2_multiplications,"
        "a2_additions,"
        "a2_comparisons,"

        /* Ratios */
        "speedup_time_x,"
        "ratio_muls_x,"
        "ratio_adds_x,"
        "ratio_cmps_x\n");
}

void write_csv_row(FILE *f, int map_id, int n_obs, double density,
                   double a1_ms, OpCount *a1,
                   double a2_ms, OpCount *a2)
{
    double sp_t  = (a2_ms   > 0) ? a1_ms              / a2_ms              : 0;
    double sp_m  = (a2->multiplications > 0)
                   ? (double)a1->multiplications / a2->multiplications : 0;
    double sp_a  = (a2->additions > 0)
                   ? (double)a1->additions       / a2->additions       : 0;
    double sp_c  = (a2->comparisons > 0)
                   ? (double)a1->comparisons     / a2->comparisons     : 0;

    fprintf(f,
        "%d,%d,%d,%d,"
        "%d,%.4f,"
        "%.6f,%lld,%lld,%lld,"
        "%.6f,%lld,%lld,%lld,"
        "%.3f,%.3f,%.3f,%.3f\n",
        map_id, H, W, KSIZE,
        n_obs, density,
        a1_ms, a1->multiplications, a1->additions, a1->comparisons,
        a2_ms, a2->multiplications, a2->additions, a2->comparisons,
        sp_t, sp_m, sp_a, sp_c);
}

/* ---------------------------------------------------------
   Build kernel — generate a symmetric cost-decay kernel
   of any odd size at runtime.
--------------------------------------------------------- */
void build_kernel(int ksize)
{
    int half = ksize / 2;
    for (int i = 0; i < ksize; i++) {
        for (int j = 0; j < ksize; j++) {
            int dy = i - half, dx = j - half;
            double dist = (double)(dy*dy + dx*dx) / (half * half);
            /* linear decay from 254 at centre to 5 at edge */
            int cost = (int)(254.0 * (1.0 - 0.98 * dist));
            if (cost < 5)  cost = 5;
            if (cost > 254) cost = 254;
            g_kernel[i * ksize + j] = (uint16_t)cost;
        }
    }
}

/* ---------------------------------------------------------
   MAIN
--------------------------------------------------------- */
int main(void)
{
    srand(42);
    build_kernel(KSIZE);

    uint8_t  *input    = malloc(H * W * sizeof(uint8_t));
    uint8_t  *out_bin  = malloc(H * W * sizeof(uint8_t));
    uint16_t *out_wgt  = malloc(H * W * sizeof(uint16_t));
    if (!input || !out_bin || !out_wgt) { perror("malloc"); return 1; }

    char csv_name[256];
    snprintf(csv_name, sizeof(csv_name),
             "opcounts_%dx%d_k%d_step%d.csv", H, W, KSIZE, OBS_STEP);

    FILE *csv = fopen(csv_name, "w");
    if (!csv) { perror("fopen"); return 1; }
    write_csv_header(csv);

    printf("\nMap %dx%d | Kernel %dx%d | Step %d obstacles\n",
           H, W, KSIZE, KSIZE, OBS_STEP);
    printf("%-6s %-9s %-8s | %-12s %-14s %-14s %-14s | "
                                 "%-12s %-14s %-14s %-14s | %-8s\n",
           "Map", "Obstacles", "Density",
           "A1 time(ms)", "A1 muls", "A1 adds", "A1 cmps",
           "A2 time(ms)", "A2 muls", "A2 adds", "A2 cmps",
           "Speedup");
    printf("%s\n", "-------------------------------------------------------------------"
                   "-------------------------------------------------------------------");

    for (int m = 0; m < NUM_MAPS; m++)
    {
        int n_obs = 10 + m * OBS_STEP;
        if (n_obs > H * W) n_obs = H * W;

        generate_map(input, n_obs);
        double density = 100.0 * n_obs / (H * W);

        /* Average over NUM_RUNS */
        double a1_ms_sum = 0.0, a2_ms_sum = 0.0;
        OpCount a1 = {0}, a2 = {0};
        int actual_obs = 0;

        for (int r = 0; r < NUM_RUNS; r++) {
            double t1, t2;
            OpCount c1, c2;

            algo1_binary_raster(input, out_bin, &c1, &t1);
            actual_obs = algo2_weighted_obstacle(input, out_wgt, &c2, &t2);

            a1_ms_sum += t1;  a2_ms_sum += t2;

            /* operation counts are deterministic — just keep last run */
            a1 = c1;  a2 = c2;
        }

        double a1_ms = a1_ms_sum / NUM_RUNS;
        double a2_ms = a2_ms_sum / NUM_RUNS;

        printf("%-6d %-9d %-8.2f | %-12.4f %-14lld %-14lld %-14lld | "
                                   "%-12.4f %-14lld %-14lld %-14lld | %.2fx\n",
               m + 1, actual_obs, density,
               a1_ms, a1.multiplications, a1.additions, a1.comparisons,
               a2_ms, a2.multiplications, a2.additions, a2.comparisons,
               (a2_ms > 0) ? a1_ms / a2_ms : 0.0);

        write_csv_row(csv, m + 1, actual_obs, density,
                      a1_ms, &a1, a2_ms, &a2);

        /* Print theoretical breakdown for first and last map */
        if (m == 0 || m == NUM_MAPS - 1)
            print_theoretical(actual_obs, density);
    }

    fclose(csv);
    printf("\nResults written to: %s\n", csv_name);

    free(input); free(out_bin); free(out_wgt);
    return 0;
}

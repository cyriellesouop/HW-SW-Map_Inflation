#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdint.h>
#include <string.h>

/* ---------------------------------------------------------
   Map dimensions and benchmark parameters
--------------------------------------------------------- */
#define H           2000
#define W           2000
#define KSIZE       3
#define NUM_MAPS    50
#define NUM_RUNS    5

#define LETHAL_OBSTACLE 254

/* ---------------------------------------------------------
   3x3 inflation kernel (uint16_t to avoid overflow in mul)
--------------------------------------------------------- */
static const uint16_t kernel3x3[KSIZE][KSIZE] = {
    { 50,  80,  50},
    { 80, 254,  80},
    { 50,  80,  50}
};

/* ---------------------------------------------------------
   Structure to hold one extracted patch and its position
   in the map. We collect all patches first, then run the
   timed multiplication loop in one contiguous block.
--------------------------------------------------------- */
typedef struct {
    uint8_t patch[KSIZE][KSIZE];   /* 3x3 values extracted from input  */
    int     y;                      /* obstacle row in the map           */
    int     x;                      /* obstacle col in the map           */
} ObstaclePatch;

/* ---------------------------------------------------------
   Clear a map
--------------------------------------------------------- */
void clear_map(uint8_t map[H][W])
{
    memset(map, 0, H * W * sizeof(uint8_t));
}

/* ---------------------------------------------------------
   Generate a map with random obstacles using Fisher-Yates.
--------------------------------------------------------- */
void generate_map(uint8_t map[H][W], int n_obstacles)
{
    int total = H * W;

    if (n_obstacles > total)
        n_obstacles = total;

    clear_map(map);

    int *cells = malloc(total * sizeof(int));
    if (!cells) { perror("malloc cells"); exit(1); }

    for (int i = 0; i < total; i++)
        cells[i] = i;

    for (int i = 0; i < n_obstacles; i++)
    {
        int j        = i + rand() % (total - i);
        int tmp      = cells[i];
        cells[i]     = cells[j];
        cells[j]     = tmp;

        map[cells[i] / W][cells[i] % W] = LETHAL_OBSTACLE;
    }

    free(cells);
}

/* ---------------------------------------------------------
   mat_mul_3x3 — element-wise (Hadamard) product.
   This is the operation the FPGA accelerates.
   max product = 254 * 254 = 64516 -> fits in uint16_t.
--------------------------------------------------------- */
void mat_mul_3x3(const uint8_t  patch [KSIZE][KSIZE],
                 const uint16_t kernel[KSIZE][KSIZE],
                       uint16_t result[KSIZE][KSIZE])
{
    for (int i = 0; i < KSIZE; i++)
        for (int j = 0; j < KSIZE; j++)
            result[i][j] = (uint16_t)patch[i][j] * kernel[i][j];
}

/* ---------------------------------------------------------
   inflate_from_obstacles_3x3

   Phase 1 — Scan & extract (NOT timed):
     Walk the map, find every obstacle, extract its 3x3
     patch, and store it in the patches array.

   Phase 2 — Multiply (TIMED):
     One single timer wraps ALL mat_mul_3x3 calls for the
     entire map.  This avoids the clock_gettime overhead
     that would distort per-call timing of a ~9-multiply
     operation.

   Phase 3 — Write back (NOT timed):
     Apply results to the output map with per-cell max.

   Returns : number of obstacles found (= number of muls)
   *mul_time_ms : total time for ALL multiplications on
                  this map in one measurement.
--------------------------------------------------------- */
int inflate_from_obstacles_3x3(uint8_t  input [H][W],
                                uint8_t  output[H][W],
                                double  *mul_time_ms)
{
    memset(output, 0, H * W * sizeof(uint8_t));
    *mul_time_ms = 0.0;

    /* -------------------------------------------------------
       Worst case: every cell is an obstacle.
       Allocate patch buffer sized to the full map.
    ------------------------------------------------------- */
    int max_patches = H * W;
    ObstaclePatch *patches = malloc(max_patches * sizeof(ObstaclePatch));
    if (!patches) { perror("malloc patches"); exit(1); }

    /* -------------------------------------------------------
       Phase 1: scan the map and collect all patches.
       NOT timed — the FPGA doesn't do this part.
    ------------------------------------------------------- */
    int n = 0;  /* obstacle / patch count */

    for (int y = 0; y < H; y++)
    {
        for (int x = 0; x < W; x++)
        {
            if (input[y][x] != LETHAL_OBSTACLE)
                continue;

            patches[n].y = y;
            patches[n].x = x;

            /* extract 3x3 neighbourhood; out-of-bound cells -> 0 */
            for (int di = 0; di < KSIZE; di++)
            {
                int ny = y + di - 1;
                for (int dj = 0; dj < KSIZE; dj++)
                {
                    int nx = x + dj - 1;
                    patches[n].patch[di][dj] =
                        (ny >= 0 && ny < H && nx >= 0 && nx < W)
                        ? input[ny][nx]
                        : 0;
                }
            }
            n++;
        }
    }

    /* -------------------------------------------------------
       Phase 2: run ALL multiplications under ONE timer.
       This is the number you compare against your FPGA.
    ------------------------------------------------------- */
    uint16_t result[KSIZE][KSIZE];   /* reused per obstacle */

    /* Allocate an array to hold all results so the write-back
       phase can use them after the timed section ends.        */
    uint16_t (*all_results)[KSIZE][KSIZE] =
        malloc(n * sizeof(*all_results));
    if (!all_results) { perror("malloc all_results"); exit(1); }

    struct timespec t0, t1;
    clock_gettime(CLOCK_MONOTONIC, &t0);

    for (int k = 0; k < n; k++)
        mat_mul_3x3(patches[k].patch, kernel3x3, all_results[k]);

    clock_gettime(CLOCK_MONOTONIC, &t1);

    *mul_time_ms = (t1.tv_sec  - t0.tv_sec)  * 1e3
                 + (t1.tv_nsec - t0.tv_nsec) / 1e6;

    /* -------------------------------------------------------
       Phase 3: write results back to the output map.
       Per-cell max handles overlapping inflation zones.
       NOT timed.
    ------------------------------------------------------- */
    for (int k = 0; k < n; k++)
    {
        int y = patches[k].y;
        int x = patches[k].x;

        for (int di = 0; di < KSIZE; di++)
        {
            int ny = y + di - 1;
            if (ny < 0 || ny >= H) continue;

            for (int dj = 0; dj < KSIZE; dj++)
            {
                int nx = x + dj - 1;
                if (nx < 0 || nx >= W) continue;

                uint8_t v = (all_results[k][di][dj] > 255)
                            ? 255
                            : (uint8_t)all_results[k][di][dj];

                if (v > output[ny][nx])
                    output[ny][nx] = v;
            }
        }
    }

    free(patches);
    free(all_results);
    return n;
}

/* ---------------------------------------------------------
   Elapsed time in milliseconds
--------------------------------------------------------- */
static inline double elapsed_ms(struct timespec a, struct timespec b)
{
    return (b.tv_sec  - a.tv_sec)  * 1e3
         + (b.tv_nsec - a.tv_nsec) / 1e6;
}

/* ---------------------------------------------------------
   MAIN
--------------------------------------------------------- */
int main(void)
{
    srand(0);

    /* --- heap allocation --- */
    uint8_t (**maps)[W] = malloc(NUM_MAPS * sizeof(*maps));
    if (!maps) { perror("malloc maps array"); return 1; }

    for (int m = 0; m < NUM_MAPS; m++)
    {
        maps[m] = malloc(H * W * sizeof(uint8_t));
        if (!maps[m]) { perror("malloc map"); return 1; }
    }

    uint8_t (*inflated)[W] = malloc(H * W * sizeof(uint8_t));
    if (!inflated) { perror("malloc inflated"); return 1; }

    /* --- benchmark parameters --- */
    const int FIRST_OBS = 10;
    const int OBS_STEP  = 50000;
    const int MAX_OBS   = H * W;

    /* --- CSV --- */
    const char *csv_name = "inflation_results_2000x2000.csv";
    FILE *csv = fopen(csv_name, "w");
    if (!csv) { perror("fopen"); return 1; }

    fprintf(csv,
        "map_name,num_obstacles,"
        "total_avg_ms,total_min_ms,total_max_ms,"   /* full inflate call */
        "mul_avg_ms,mul_min_ms,mul_max_ms,"         /* mat_mul only      */
        "num_multiplications\n");

    /* --- main benchmark loop --- */
    for (int m = 0; m < NUM_MAPS; m++)
    {
        int num_obstacles = FIRST_OBS + m * OBS_STEP;
        if (num_obstacles > MAX_OBS) num_obstacles = MAX_OBS;

        generate_map(maps[m], num_obstacles);

        double total_sum = 0.0, total_min = 1e18, total_max = 0.0;
        double mul_sum   = 0.0, mul_min   = 1e18, mul_max   = 0.0;
        int    n_mul     = 0;

        for (int r = 0; r < NUM_RUNS; r++)
        {
            double mul_time_ms = 0.0;

            struct timespec t0, t1;
            clock_gettime(CLOCK_MONOTONIC, &t0);

            n_mul = inflate_from_obstacles_3x3(maps[m], inflated, &mul_time_ms);

            clock_gettime(CLOCK_MONOTONIC, &t1);

            double dt = elapsed_ms(t0, t1);

            total_sum += dt;
            if (dt < total_min) total_min = dt;
            if (dt > total_max) total_max = dt;

            mul_sum += mul_time_ms;
            if (mul_time_ms < mul_min) mul_min = mul_time_ms;
            if (mul_time_ms > mul_max) mul_max = mul_time_ms;
        }

        double total_avg = total_sum / NUM_RUNS;
        double mul_avg   = mul_sum   / NUM_RUNS;

        fprintf(csv,
            "Map_%d,%d,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%d\n",
            m + 1, num_obstacles,
            total_avg, total_min, total_max,
            mul_avg,   mul_min,   mul_max,
            n_mul);

        printf("Map_%02d | Obs=%7d | muls=%7d | "
               "total avg=%.4f ms | mul-only avg=%.4f ms\n",
               m + 1, num_obstacles, n_mul, total_avg, mul_avg);
    }

    fclose(csv);

    for (int m = 0; m < NUM_MAPS; m++) free(maps[m]);
    free(maps);
    free(inflated);

    printf("\nResults written to %s\n", csv_name);
    return 0;
}

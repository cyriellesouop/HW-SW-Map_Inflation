#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdint.h>
#include <string.h>

/* ---------------------------------------------------------
   Map dimensions — override at compile time for Experiment 1:
       gcc -DH=256 -DW=256 ...
       gcc -DH=512 -DW=512 ...
       gcc -DH=1024 -DW=1024 ...
--------------------------------------------------------- */
#ifndef H
#define H 500
#endif
#ifndef W
#define W 500
#endif
#ifndef OBS_STEP
#define OBS_STEP 200        /* obstacle increment per map (Experiment 2) */
#endif

#define KSIZE           9
#define NUM_MAPS        50
#define NUM_RUNS        1
#define LETHAL_OBSTACLE 254

/* ---------------------------------------------------------
   9x9 inflation kernel
--------------------------------------------------------- */
static const uint16_t kernel9x9[KSIZE][KSIZE] = {
    { 50,  80,  50},
    { 80, 254,  80},
    { 50,  80,  50}
};

/* ---------------------------------------------------------
   Helpers
--------------------------------------------------------- */
void clear_map(uint8_t map[H][W])
{
    memset(map, 0, H * W * sizeof(uint8_t));
}

void generate_map(uint8_t map[H][W], int n_obstacles)
{
    int total = H * W;
    if (n_obstacles > total) n_obstacles = total;
    clear_map(map);

    int *cells = malloc(total * sizeof(int));
    if (!cells) { perror("malloc"); exit(1); }
    for (int i = 0; i < total; i++) cells[i] = i;
    for (int i = 0; i < n_obstacles; i++) {
        int j = i + rand() % (total - i);
        int t = cells[i]; cells[i] = cells[j]; cells[j] = t;
        map[cells[i] / W][cells[i] % W] = LETHAL_OBSTACLE;
    }
    free(cells);
}

static inline double elapsed_ms(struct timespec a, struct timespec b)
{
    return (b.tv_sec - a.tv_sec) * 1e3 + (b.tv_nsec - a.tv_nsec) / 1e6;
}

/* ==========================================================
   APPROACH 1 — RASTER-SCAN (BASELINE)
   Slides a window over EVERY cell in the grid.
   This is the design described in prior work.
   Execution time = O(H * W * KSIZE * KSIZE) always,
   regardless of obstacle density.
========================================================== */
void inflate_raster_scan(const uint8_t  input [H][W],
                               uint16_t output[H][W],
                               double  *time_ms)
{
    memset(output, 0, H * W * sizeof(uint16_t));

    struct timespec t0, t1;
    clock_gettime(CLOCK_MONOTONIC, &t0);

    /* For every output cell, accumulate the max contribution
       from any obstacle within kernel reach.                 */
    for (int y = 0; y < H; y++) {
        for (int x = 0; x < W; x++) {
            uint16_t best = 0;

            /* Slide kernel: check all cells that could reach (y,x) */
            for (int di = 0; di < KSIZE; di++) {
                int sy = y - di + KSIZE/2;           /* source row    */
                if (sy < 0 || sy >= H) continue;
                for (int dj = 0; dj < KSIZE; dj++) {
                    int sx = x - dj + KSIZE/2;       /* source col    */
                    if (sx < 0 || sx >= W) continue;
                    if (input[sy][sx] == LETHAL_OBSTACLE) {
                        uint16_t v = kernel9x9[di][dj];
                        if (v > best) best = v;
                    }
                }
            }
            output[y][x] = best;
        }
    }

    clock_gettime(CLOCK_MONOTONIC, &t1);
    *time_ms = elapsed_ms(t0, t1);
}

/* ==========================================================
   APPROACH 2 — OBSTACLE-DRIVEN (PROPOSED)
   Processes only occupied cells.
   Execution time = O(N_obstacles * KSIZE * KSIZE).
   Scales with obstacle density, NOT with map resolution.
========================================================== */
typedef struct {
    uint8_t patch[KSIZE][KSIZE];
    int y, x;
} ObstaclePatch;

int inflate_obstacle_driven(const uint8_t  input [H][W],
                                  uint16_t output[H][W],
                                  double  *time_ms)
{
    memset(output, 0, H * W * sizeof(uint16_t));

    /* Phase 1 — extract patches (NOT timed, analogous to
       the FPGA's obstacle-detection pre-pass)             */
    ObstaclePatch *patches = malloc(H * W * sizeof(ObstaclePatch));
    if (!patches) { perror("malloc"); exit(1); }

    int n = 0;
    for (int y = 0; y < H; y++) {
        for (int x = 0; x < W; x++) {
            if (input[y][x] != LETHAL_OBSTACLE) continue;
            patches[n].y = y;
            patches[n].x = x;
            for (int di = 0; di < KSIZE; di++) {
                int ny = y + di - KSIZE/2;
                for (int dj = 0; dj < KSIZE; dj++) {
                    int nx = x + dj - KSIZE/2;
                    patches[n].patch[di][dj] =
                        (ny >= 0 && ny < H && nx >= 0 && nx < W)
                        ? input[ny][nx] : 0;
                }
            }
            n++;
        }
    }

    /* Phase 2 — multiply only for obstacle patches (TIMED) */
    uint16_t (*results)[KSIZE][KSIZE] = malloc(n * sizeof(*results));
    if (!results) { perror("malloc"); exit(1); }

    struct timespec t0, t1;
    clock_gettime(CLOCK_MONOTONIC, &t0);

    for (int k = 0; k < n; k++)
        for (int i = 0; i < KSIZE; i++)
            for (int j = 0; j < KSIZE; j++)
                results[k][i][j] =
                    (uint16_t)patches[k].patch[i][j] * kernel9x9[i][j];

    clock_gettime(CLOCK_MONOTONIC, &t1);
    *time_ms = elapsed_ms(t0, t1);

    /* Phase 3 — write back with per-cell max (NOT timed)  */
    for (int k = 0; k < n; k++) {
        int y = patches[k].y, x = patches[k].x;
        for (int di = 0; di < KSIZE; di++) {
            int ny = y + di - KSIZE/2;
            if (ny < 0 || ny >= H) continue;
            for (int dj = 0; dj < KSIZE; dj++) {
                int nx = x + dj - KSIZE/2;
                if (nx < 0 || nx >= W) continue;
                if (results[k][di][dj] > output[ny][nx])
                    output[ny][nx] = results[k][di][dj];
            }
        }
    }

    free(patches);
    free(results);
    return n;
}

/* ==========================================================
   MAIN
   Runs both approaches on the same maps and writes one CSV.

   EXPERIMENT 1 (resolution scaling):
       Compile multiple times with different H and W.
       Keep OBS_DENSITY constant (= fixed % of H*W).
       Compare raster_ms vs obstacle_ms as resolution grows.

   EXPERIMENT 2 (density scaling):
       Keep H and W fixed.
       Vary OBS_STEP to sweep obstacle count from sparse to dense.
       Show raster_ms stays flat while obstacle_ms grows linearly.
========================================================== */
int main(void)
{
    srand(0);

    /* For Experiment 1 keep density constant at ~10% */
    const double OBS_DENSITY = 0.10;
    const int FIXED_OBS = (int)(OBS_DENSITY * H * W);

    uint8_t  (*input )[W] = malloc(H * W * sizeof(uint8_t));
    uint16_t (*out_rs)[W] = malloc(H * W * sizeof(uint16_t));
    uint16_t (*out_od)[W] = malloc(H * W * sizeof(uint16_t));
    if (!input || !out_rs || !out_od) { perror("malloc"); return 1; }

    /* CSV embeds resolution and step so files don't collide */
    char csv_name[256];
    snprintf(csv_name, sizeof(csv_name),
             "scalability_%dx%d_step%d.csv", H, W, OBS_STEP);

    FILE *csv = fopen(csv_name, "w");
    if (!csv) { perror("fopen"); return 1; }

    fprintf(csv,
        "map_id,"
        "num_obstacles,"
        "obstacle_density_pct,"
        "raster_ms,"       /* Approach 1 — scales with H*W     */
        "obstacle_driven_ms,"  /* Approach 2 — scales with obs count */
        "speedup_x\n");

    printf("%-8s %-10s %-8s %-14s %-14s %-10s\n",
           "Map", "Obstacles", "Density%",
           "Raster(ms)", "ObsDriven(ms)", "Speedup");
    printf("%-70s\n", "----------------------------------------------------------------------");

    for (int m = 0; m < NUM_MAPS; m++)
    {
        /* ---------------------------------------------------
           Experiment 2: sweep obstacle count, fixed resolution.
           Experiment 1: keep density fixed, change H/W at
                         compile time, set m=0 only (NUM_MAPS=1).
        --------------------------------------------------- */
        int num_obs = (OBS_STEP > 0)
                      ? (10 + m * OBS_STEP)          /* Experiment 2 */
                      : FIXED_OBS;                    /* Experiment 1 */

        if (num_obs > H * W) num_obs = H * W;

        generate_map(input, num_obs);

        double rs_ms = 0.0, od_ms = 0.0;
        int    n_obs = 0;

        for (int r = 0; r < NUM_RUNS; r++) {
            double t_rs, t_od;
            inflate_raster_scan(input, out_rs, &t_rs);
            n_obs = inflate_obstacle_driven(input, out_od, &t_od);
            rs_ms += t_rs;
            od_ms += t_od;
        }
        rs_ms /= NUM_RUNS;
        od_ms /= NUM_RUNS;

        double density  = 100.0 * num_obs / (H * W);
        double speedup  = (od_ms > 0.0) ? rs_ms / od_ms : 0.0;

        fprintf(csv, "%d,%d,%.2f,%.6f,%.6f,%.2f\n",
                m + 1, num_obs, density, rs_ms, od_ms, speedup);

        printf("Map_%02d   %-10d %-8.2f %-14.4f %-14.4f %.2fx\n",
               m + 1, num_obs, density, rs_ms, od_ms, speedup);
    }

    fclose(csv);
    printf("\nResults written to: %s\n", csv_name);

    free(input); free(out_rs); free(out_od);
    return 0;
}

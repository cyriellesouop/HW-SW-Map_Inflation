#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdint.h>
#include <string.h>

/* ---------------------------------------------------------
   Map dimensions and benchmark parameters.
   H, W, and OBS_STEP can be overridden at compile time:
       gcc -DH=1000 -DW=1000 -DOBS_STEP=10000 ...
--------------------------------------------------------- */
#ifndef H
#define H           2000
#endif

#ifndef W
#define W           2000
#endif

#ifndef OBS_STEP
#define OBS_STEP    50000
#endif

#define KSIZE       3
#define NUM_MAPS    50
#define NUM_RUNS    5

#define LETHAL_OBSTACLE 254

/* ---------------------------------------------------------
   3x3 inflation kernel
--------------------------------------------------------- */
static const uint16_t kernel3x3[KSIZE][KSIZE] = {
    { 50,  80,  50},
    { 80, 254,  80},
    { 50,  80,  50}
};

/* ---------------------------------------------------------
   Structure to hold one extracted patch and its position
--------------------------------------------------------- */
typedef struct {
    uint8_t patch[KSIZE][KSIZE];
    int     y;
    int     x;
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
   No clamping — values are left as-is (uint16_t).
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

   Phase 1 — Scan & extract (NOT timed)
   Phase 2 — Multiply, all under ONE timer (TIMED)
   Phase 3 — Write back with per-cell max (NOT timed)

   Output is uint16_t — no clamping applied.
   Returns : number of obstacles found (= number of muls)
   *mul_time_ms : total time for ALL multiplications
--------------------------------------------------------- */
int inflate_from_obstacles_3x3(uint8_t   input [H][W],
                                uint16_t  output[H][W],
                                double   *mul_time_ms)
{
    memset(output, 0, H * W * sizeof(uint16_t));
    *mul_time_ms = 0.0;

    ObstaclePatch *patches = malloc(H * W * sizeof(ObstaclePatch));
    if (!patches) { perror("malloc patches"); exit(1); }

    /* -------------------------------------------------------
       Phase 1: scan the map and collect all patches.
    ------------------------------------------------------- */
    int n = 0;

    for (int y = 0; y < H; y++)
    {
        for (int x = 0; x < W; x++)
        {
            if (input[y][x] != LETHAL_OBSTACLE)
                continue;

            patches[n].y = y;
            patches[n].x = x;

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
    ------------------------------------------------------- */
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
       Phase 3: write results back to output map.
       Per-cell max, no clamping.
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

                if (all_results[k][di][dj] > output[ny][nx])
                    output[ny][nx] = all_results[k][di][dj];
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
   save_generated_json
   Saves all input maps to a JSON file.
   Each entry: id, num_obstacles, data (2D array, uint8_t).
--------------------------------------------------------- */
void save_generated_json(const char  *filename,
                         uint8_t (**maps)[W],
                         const int   *obstacle_counts,
                         int          num_maps)
{
    FILE *f = fopen(filename, "w");
    if (!f) { perror("fopen generated.json"); return; }

    fprintf(f, "{\n  \"maps\": [\n");

    for (int m = 0; m < num_maps; m++)
    {
        fprintf(f, "    {\n");
        fprintf(f, "      \"id\": %d,\n",             m + 1);
        fprintf(f, "      \"num_obstacles\": %d,\n",  obstacle_counts[m]);
        fprintf(f, "      \"data\": [\n");

        for (int y = 0; y < H; y++)
        {
            fprintf(f, "        [");
            for (int x = 0; x < W; x++)
            {
                fprintf(f, "%u", maps[m][y][x]);
                if (x < W - 1) fprintf(f, ",");
            }
            fprintf(f, "]");
            if (y < H - 1) fprintf(f, ",");
            fprintf(f, "\n");
        }

        fprintf(f, "      ]\n    }");
        if (m < num_maps - 1) fprintf(f, ",");
        fprintf(f, "\n");
    }

    fprintf(f, "  ]\n}\n");
    fclose(f);
    printf("Generated maps saved to %s\n", filename);
}

/* ---------------------------------------------------------
   save_results_json
   Saves all inflated output maps to a JSON file.
   Each entry: id, num_obstacles, data (2D array, uint16_t).
   Values are not clamped — raw multiplication results.
--------------------------------------------------------- */
void save_results_json(const char    *filename,
                       uint16_t (**inflated_maps)[W],
                       const int     *obstacle_counts,
                       int            num_maps)
{
    FILE *f = fopen(filename, "w");
    if (!f) { perror("fopen result.json"); return; }

    fprintf(f, "{\n  \"maps\": [\n");

    for (int m = 0; m < num_maps; m++)
    {
        fprintf(f, "    {\n");
        fprintf(f, "      \"id\": %d,\n",             m + 1);
        fprintf(f, "      \"num_obstacles\": %d,\n",  obstacle_counts[m]);
        fprintf(f, "      \"data\": [\n");

        for (int y = 0; y < H; y++)
        {
            fprintf(f, "        [");
            for (int x = 0; x < W; x++)
            {
                fprintf(f, "%u", inflated_maps[m][y][x]);
                if (x < W - 1) fprintf(f, ",");
            }
            fprintf(f, "]");
            if (y < H - 1) fprintf(f, ",");
            fprintf(f, "\n");
        }

        fprintf(f, "      ]\n    }");
        if (m < num_maps - 1) fprintf(f, ",");
        fprintf(f, "\n");
    }

    fprintf(f, "  ]\n}\n");
    fclose(f);
    printf("Inflated maps saved to %s\n", filename);
}

/* ---------------------------------------------------------
   MAIN
--------------------------------------------------------- */
int main(void)
{
    srand(0);

    /* --- allocate input maps --- */
    uint8_t (**maps)[W] = malloc(NUM_MAPS * sizeof(*maps));
    if (!maps) { perror("malloc maps"); return 1; }

    for (int m = 0; m < NUM_MAPS; m++)
    {
        maps[m] = malloc(H * W * sizeof(uint8_t));
        if (!maps[m]) { perror("malloc map"); return 1; }
    }

    /* --- allocate inflated output maps (uint16_t, no clamping) --- */
    uint16_t (**inflated_maps)[W] = malloc(NUM_MAPS * sizeof(*inflated_maps));
    if (!inflated_maps) { perror("malloc inflated_maps"); return 1; }

    for (int m = 0; m < NUM_MAPS; m++)
    {
        inflated_maps[m] = malloc(H * W * sizeof(uint16_t));
        if (!inflated_maps[m]) { perror("malloc inflated map"); return 1; }
    }

    /* --- store obstacle count per map --- */
    int obstacle_counts[NUM_MAPS];

    /* --- benchmark parameters --- */
    const int FIRST_OBS = 10;
    const int MAX_OBS   = H * W;

    /* --- CSV filename embeds matrix size and step --- */
    char csv_name[128];
    snprintf(csv_name, sizeof(csv_name),
             "inflation_results_%dx%d_step%d.csv", H, W, OBS_STEP);

    FILE *csv = fopen(csv_name, "w");
    if (!csv) { perror("fopen csv"); return 1; }

    /* CSV header — includes both sum and avg for total and mul */
    fprintf(csv,
        "map_name,"
        "num_obstacles,"
        "total_sum_ms,total_avg_ms,total_min_ms,total_max_ms,"
        "mul_sum_ms,mul_avg_ms,mul_min_ms,mul_max_ms,"
        "num_multiplications\n");

    /* --- main benchmark loop --- */
    for (int m = 0; m < NUM_MAPS; m++)
    {
        int num_obstacles = FIRST_OBS + m * OBS_STEP;
        if (num_obstacles > MAX_OBS) num_obstacles = MAX_OBS;

        obstacle_counts[m] = num_obstacles;

        generate_map(maps[m], num_obstacles);

        double total_sum = 0.0, total_min = 1e18, total_max = 0.0;
        double mul_sum   = 0.0, mul_min   = 1e18, mul_max   = 0.0;
        int    n_mul     = 0;

        for (int r = 0; r < NUM_RUNS; r++)
        {
            double mul_time_ms = 0.0;

            struct timespec t0, t1;
            clock_gettime(CLOCK_MONOTONIC, &t0);

            n_mul = inflate_from_obstacles_3x3(maps[m],
                                               inflated_maps[m],
                                               &mul_time_ms);

            clock_gettime(CLOCK_MONOTONIC, &t1);

            double dt = elapsed_ms(t0, t1);

            /* accumulate total timing */
            total_sum += dt;
            if (dt < total_min) total_min = dt;
            if (dt > total_max) total_max = dt;

            /* accumulate multiplication-only timing */
            mul_sum += mul_time_ms;
            if (mul_time_ms < mul_min) mul_min = mul_time_ms;
            if (mul_time_ms > mul_max) mul_max = mul_time_ms;
        }

        double total_avg = total_sum / NUM_RUNS;
        double mul_avg   = mul_sum   / NUM_RUNS;

        fprintf(csv,
            "Map_%d,%d,"
            "%.6f,%.6f,%.6f,%.6f,"   /* total: sum, avg, min, max */
            "%.6f,%.6f,%.6f,%.6f,"   /* mul:   sum, avg, min, max */
            "%d\n",
            m + 1, num_obstacles,
            total_sum, total_avg, total_min, total_max,
            mul_sum,   mul_avg,   mul_min,   mul_max,
            n_mul);

        printf("Map_%02d | Obs=%7d | muls=%7d | "
               "total avg=%.4f ms (sum=%.4f ms) | "
               "mul avg=%.4f ms (sum=%.4f ms)\n",
               m + 1, num_obstacles, n_mul,
               total_avg, total_sum,
               mul_avg,   mul_sum);
    }

    fclose(csv);
    printf("\nResults written to %s\n\n", csv_name);

    /* --- save generated input maps to JSON --- */
    save_generated_json("generated.json",
                        maps,
                        obstacle_counts,
                        NUM_MAPS);

    /* --- save inflated output maps to JSON --- */
    save_results_json("result.json",
                      inflated_maps,
                      obstacle_counts,
                      NUM_MAPS);

    /* --- cleanup --- */
    for (int m = 0; m < NUM_MAPS; m++) free(maps[m]);
    free(maps);

    for (int m = 0; m < NUM_MAPS; m++) free(inflated_maps[m]);
    free(inflated_maps);

    return 0;
}

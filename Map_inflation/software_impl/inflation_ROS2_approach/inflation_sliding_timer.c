#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdint.h>

#define H 384
#define W 384

#define NUM_MAPS 50
#define MAX_OBSTACLES 60

#define LETHAL_OBSTACLE 254

/* ---------------------------------------------------------
   Simple 3x3 inflation kernel (radius = 1)
   center included
--------------------------------------------------------- */
static const float kernel3x3[3][3] = {
    {50.0f, 80.0f, 50.0f},
    {80.0f, 254.0f, 80.0f},
    {50.0f, 80.0f, 50.0f}
};


/* ---------------------------------------------------------
   Clear a map
--------------------------------------------------------- */
void clear_map(unsigned char map[H][W])
{
    for (int y = 0; y < H; y++)
        for (int x = 0; x < W; x++)
            map[y][x] = 0;
}


/* ---------------------------------------------------------
   Generate a map with exactly n obstacles
--------------------------------------------------------- */
void generate_map(unsigned char map[H][W], int n_obstacles)
{
    clear_map(map);

    int placed = 0;

    while (placed < n_obstacles)
    {
        int x = rand() % W;
        int y = rand() % H;

        if (map[y][x] != LETHAL_OBSTACLE)
        {
            map[y][x] = LETHAL_OBSTACLE;
            placed++;
        }
    }
}


/* ---------------------------------------------------------
   Obstacle-based inflation (NO sliding window scan)

   1) detect all obstacles
   2) inflate only around each obstacle (3x3)
--------------------------------------------------------- */
void inflate_from_obstacles_3x3(
        unsigned char input[H][W],
        float output[H][W])
{
    /* initialize output */
    for (int y = 0; y < H; y++)
        for (int x = 0; x < W; x++)
            output[y][x] = 0.0f;

    /* detect obstacles and inflate locally */
    for (int y = 0; y < H; y++)
    {
        for (int x = 0; x < W; x++)
        {
            if (input[y][x] == LETHAL_OBSTACLE)
            {
                for (int dy = -1; dy <= 1; dy++)
                {
                    for (int dx = -1; dx <= 1; dx++)
                    {
                        int ny = y + dy;
                        int nx = x + dx;

                        if (nx < 0 || nx >= W || ny < 0 || ny >= H)
                            continue;

                        float v = kernel3x3[dy + 1][dx + 1];

                        if (v > output[ny][nx])
                            output[ny][nx] = v;
                    }
                }
            }
        }
    }
}


/* ---------------------------------------------------------
   Time helper (microseconds)
--------------------------------------------------------- */
double time_us(struct timespec a, struct timespec b)
{
    return (b.tv_sec - a.tv_sec) * 1e6 +
           (b.tv_nsec - a.tv_nsec) / 1e3;
}


/* ---------------------------------------------------------
   MAIN
--------------------------------------------------------- */
int main(void)
{
    srand(0);

    unsigned char maps[NUM_MAPS][H][W];
    float inflated[H][W];

    int FIRST_OBS = 10;
    int OBS_STEP  = 50;

    FILE *csv = fopen("inflation_no_sliding_times.csv", "w");
    if (!csv)
    {
        perror("fopen");
        return 1;
    }

    /* CSV header */
    fprintf(csv, "matrix_name,time_ms\n");

    /* Generate and process maps */
    for (int m = 0; m < NUM_MAPS; m++)
    {
        int num_obstacles = FIRST_OBS + m * OBS_STEP;

        /* generate map with deterministic obstacle count */
        generate_map(maps[m], num_obstacles);

        struct timespec t0, t1;
        clock_gettime(CLOCK_MONOTONIC, &t0);

        inflate_from_obstacles_3x3(maps[m], inflated);

        clock_gettime(CLOCK_MONOTONIC, &t1);

        /* compute elapsed time in milliseconds */
        double dt_ms = ((t1.tv_sec - t0.tv_sec) * 1000.0) +
                       ((t1.tv_nsec - t0.tv_nsec) / 1e6);

        /* write CSV row */
        fprintf(csv, "Map_%d,%.6f\n", num_obstacles, dt_ms);

        /* print to console */
        printf("Map_%d : %.3f ms\n", num_obstacles, dt_ms);
    }

    fclose(csv);

    printf("\nResults written to inflation_times.csv\n");

    return 0;
}

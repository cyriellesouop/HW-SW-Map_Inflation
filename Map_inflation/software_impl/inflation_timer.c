#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <math.h>
#include <time.h>

#define H 384
#define W 384

#define NUM_MAPS     50
#define FIRST_OBS    10
#define OBS_STEP     50
#define MAX_OBS      (FIRST_OBS + (NUM_MAPS-1)*OBS_STEP)

#define KERNEL_SIZE  3
#define LETHAL_OBSTACLE 254

/* ------------------------------------------------------
 * Input maps
 * ------------------------------------------------------*/
static uint8_t maps[NUM_MAPS][H][W];

/* ------------------------------------------------------
 * Obstacle list
 * ------------------------------------------------------*/
static struct {
    uint16_t r;
    uint16_t c;
} obstacle_list[MAX_OBS];

/* ------------------------------------------------------
 * Deterministic obstacle coordinates
 * ------------------------------------------------------*/
static void build_obstacle_list(void)
{
    int k = 0;

    for (int i = 0; i < H && k < MAX_OBS; ++i)
        for (int j = 0; j < W && k < MAX_OBS; ++j) {
            obstacle_list[k].r = (uint16_t)i;
            obstacle_list[k].c = (uint16_t)j;
            k++;
        }
}

/* ------------------------------------------------------*/
static void init_map(uint8_t map[H][W], int obstacle_count)
{
    memset(map, 0, H * W * sizeof(uint8_t));

    for (int i = 0; i < obstacle_count; ++i)
        map[obstacle_list[i].r][obstacle_list[i].c] = LETHAL_OBSTACLE;
}

/* ------------------------------------------------------*/
static void init_all_maps(void)
{
    build_obstacle_list();

    for (int m = 0; m < NUM_MAPS; ++m) {
        int obstacle_count = FIRST_OBS + m * OBS_STEP;
        init_map(maps[m], obstacle_count);
    }
}

/* ===========================================================
 * 3x3 kernel
 * =========================================================== */
void precompute_kernel_3x3(float kernel[3][3],
                           float cost_scaling_factor,
                           float inscribed_radius,
                           float resolution_map)
{
    const int inflation_radius = 1;

    for (int dy = -1; dy <= 1; dy++) {
        for (int dx = -1; dx <= 1; dx++) {

            float distance =
                resolution_map * sqrtf((float)(dx*dx + dy*dy));

            float value;

            if (distance > inflation_radius * resolution_map)
                value = 0.0f;
            else if (distance <= inscribed_radius)
                value = (float)LETHAL_OBSTACLE;
            else
                value = 253.0f *
                        expf(-cost_scaling_factor *
                             (distance - inscribed_radius));

            if (value < 0.0f)
                value = 0.0f;

            kernel[dy + 1][dx + 1] = value;
        }
    }
}

/* ===========================================================
 * 3x3 sliding window inflation
 * =========================================================== */
void map_inflation_3x3(int height, int width,
                       const uint8_t costmap_in[height][width],
                       const float kernel[3][3],
                       float inflated_map[height][width])
{
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {

            float max_cost = (float)costmap_in[y][x];

            for (int dy = -1; dy <= 1; dy++) {
                for (int dx = -1; dx <= 1; dx++) {

                    int ny = y + dy;
                    int nx = x + dx;

                    if (nx < 0 || nx >= width || ny < 0 || ny >= height)
                        continue;

                    if (costmap_in[ny][nx] == LETHAL_OBSTACLE) {

                        float infl_value =
                            kernel[dy + 1][dx + 1];

                        if (infl_value > max_cost)
                            max_cost = infl_value;
                    }
                }
            }

            inflated_map[y][x] = max_cost;
        }
    }
}

/* ===========================================================
 * Timing helper
 * =========================================================== */
static inline double elapsed_ms(struct timespec a,
                                 struct timespec b)
{
    return (b.tv_sec - a.tv_sec) * 1000.0 +
           (b.tv_nsec - a.tv_nsec) / 1e6;
}

/* ===========================================================
 * Main
 * =========================================================== */
int main(void)
{
    static float inflated_map[H][W];
    float kernel[3][3];

    float cost_scaling_factor = 3.0f;
    float inscribed_radius    = 0.325f;
    float resolution_map      = 1.0f;

    init_all_maps();

    precompute_kernel_3x3(kernel,
                           cost_scaling_factor,
                           inscribed_radius,
                           resolution_map);

    FILE *csv = fopen("inflation_times.csv", "w");
    if (!csv) {
        perror("fopen");
        return 1;
    }

    /* CSV header */
    fprintf(csv, "matrix_name,time_ms\n");

    double total_ms = 0.0;

    for (int m = 0; m < NUM_MAPS; ++m) {

        struct timespec t0, t1;

        clock_gettime(CLOCK_MONOTONIC, &t0);

        map_inflation_3x3(H, W,
                           maps[m],
                           kernel,
                           inflated_map);

        clock_gettime(CLOCK_MONOTONIC, &t1);

        double ms = elapsed_ms(t0, t1);
        total_ms += ms;

        int num_obstacles = FIRST_OBS + m * OBS_STEP;

        /* matrix name format: Map_numberOfObstacles */
        fprintf(csv, "Map_%d,%.6f\n", num_obstacles, ms);

        printf("Map_%d : %.3f ms\n", num_obstacles, ms);
    }

    fclose(csv);

    printf("\nAverage per map : %.3f ms\n",
           total_ms / NUM_MAPS);

    printf("CSV written to inflation_times.csv\n");

    return 0;
}

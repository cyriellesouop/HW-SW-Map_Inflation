#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>

/* ---------------- Configuration ---------------- */
#define W 100
#define H 100
#define LETHAL_OBSTACLE 254
#define FREE_SPACE 0

#define NUM_COSTMAPS 20   // Number of random maps to generate

/* ---------------- Kernel computation ---------------- */
/*
 * Computes inflation cost for a relative offset (dx, dy)
 */
float kernel_compute(int dx, int dy,
                     int inflation_radius,
                     float cost_scaling_factor,
                     float inscribed_radius,
                     float resolution)
{
    /* Convert grid distance to metric distance */
    float dist = resolution * sqrtf(dx * dx + dy * dy);

    /* Inside robot footprint → lethal */
    if (dist <= inscribed_radius)
        return (float)LETHAL_OBSTACLE;

    /* Outside inflation radius → no cost */
    if (dist > inflation_radius * resolution)
        return 0.0f;

    /* Exponential decay */
    return (float)LETHAL_OBSTACLE *
           expf(-cost_scaling_factor * (dist - inscribed_radius));
}

/* ---------------- Inflation computation ---------------- */
void map_inflation_compute(
    int costmap_in[H][W],
    float cost_scaling_factor,
    int inflation_radius,
    float inscribed_radius,
    float resolution,
    float inflated_map[H][W])
{
    int K = 2 * inflation_radius + 1;
    float kernel[K][K];

    /* Precompute kernel */
    for (int dy = -inflation_radius; dy <= inflation_radius; dy++) {
        for (int dx = -inflation_radius; dx <= inflation_radius; dx++) {
            kernel[dy + inflation_radius][dx + inflation_radius] =
                kernel_compute(dx, dy,
                               inflation_radius,
                               cost_scaling_factor,
                               inscribed_radius,
                               resolution);
        }
    }

    /* Sliding-window inflation */
    for (int y = 0; y < H; y++) {
        for (int x = 0; x < W; x++) {

            float max_cost = costmap_in[y][x];

            for (int dy = -inflation_radius; dy <= inflation_radius; dy++) {
                for (int dx = -inflation_radius; dx <= inflation_radius; dx++) {

                    int ny = y + dy;
                    int nx = x + dx;

                    /* Boundary check */
                    if (nx < 0 || nx >= W || ny < 0 || ny >= H)
                        continue;

                    /* Inflate only from obstacles */
                    if (costmap_in[ny][nx] == LETHAL_OBSTACLE) {
                        float val =
                            kernel[dy + inflation_radius]
                                  [dx + inflation_radius];
                        if (val > max_cost)
                            max_cost = val;
                    }
                }
            }
            inflated_map[y][x] = max_cost;
        }
    }
}

/* ---------------- Random cluttered costmap generator ---------------- */
/*
 * Generates clustered (realistic) obstacles
 */
void generate_random_cluttered_costmap(int map[H][W],
                                       int num_clusters,
                                       int max_radius)
{
    /* Initialize free space */
    for (int y = 0; y < H; y++)
        for (int x = 0; x < W; x++)
            map[y][x] = FREE_SPACE;

    /* Generate obstacle clusters */
    for (int c = 0; c < num_clusters; c++) {

        int cx = rand() % W;
        int cy = rand() % H;
        int radius = 1 + rand() % max_radius;

        for (int dy = -radius; dy <= radius; dy++) {
            for (int dx = -radius; dx <= radius; dx++) {

                if (dx*dx + dy*dy > radius*radius)
                    continue;   // circular cluster

                int nx = cx + dx;
                int ny = cy + dy;

                if (nx >= 0 && nx < W && ny >= 0 && ny < H)
                    map[ny][nx] = LETHAL_OBSTACLE;
            }
        }
    }
}

/* ---------------- Print helpers ---------------- */
void print_costmap_int(const char *title, int map[H][W])
{
    printf("\n=== %s ===\n", title);
    for (int y = H - 1; y >= 0; y--) {
        for (int x = 0; x < W; x++) {
            if (map[y][x] == LETHAL_OBSTACLE)
                printf(" X ");
            else
                printf("%2d ", map[y][x]);
        }
        printf("\n");
    }
}

void print_costmap_float(const char *title, float map[H][W])
{
    printf("\n=== %s ===\n", title);
    for (int y = H - 1; y >= 0; y--) {
        for (int x = 0; x < W; x++) {
            if (map[y][x] >= LETHAL_OBSTACLE)
                printf(" X ");
            else
                printf("%3.0f ", map[y][x]);
        }
        printf("\n");
    }
}

/* ---------------- Main ---------------- */
int main(void)
{
    srand((unsigned int)time(NULL));

    /* ROS-like parameters */
    float resolution_map     = 0.05f;   // 5 cm per cell
    float inscribed_radius   = 0.325f;  // robot radius (m)
    int   inflation_radius   = 6;       // cells (~30 cm)
    float cost_scaling_factor = 3.0f;

    for (int i = 0; i < NUM_COSTMAPS; i++) {

        int   costmap[H][W];
        float inflated_map[H][W];

        generate_random_cluttered_costmap(
            costmap,
            30,   // number of obstacle clusters
            4     // max cluster radius (cells)
        );

   //     print_costmap_int("Input Costmap", costmap);

        map_inflation_compute(costmap,
                              cost_scaling_factor,
                              inflation_radius,
                              inscribed_radius,
                              resolution_map,
                              inflated_map);

   //     print_costmap_float("Inflated Costmap", inflated_map);
    }

    return 0;
}

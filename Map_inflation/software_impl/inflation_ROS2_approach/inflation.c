#include <stdio.h>
#include <stdlib.h>
#include <math.h>

// Define the value for lethal obstacles
#define LETHAL_OBSTACLE 254

// ===========================================================
// Sub-function: compute the kernel value for a given offset
// ===========================================================
float kernel_compute(int dx, int dy, int inflation_radius, float cost_scaling_factor, float inscribed_radius, float resolution_map) {
    // Compute Euclidean distance from the center (dx, dy) in meters
    float distance = resolution_map * sqrt(dx*dx + dy*dy);

    // If distance is outside the inflation radius, return 0 (no cost contribution)
    if (distance > inflation_radius * resolution_map) 
        return 0.0;

    // If distance is inside the inscribed radius, return max cost (lethal obstacle)
    if (distance <= inscribed_radius) 
        return (float)LETHAL_OBSTACLE;

    // Otherwise, compute the cost with an exponential decay based on distance
    float cost = 253.0f * expf(-cost_scaling_factor * (distance - inscribed_radius));

    // Ensure cost is not negative
    if (cost < 0.0f) 
        cost = 0.0f;

    return cost;
}

// ===========================================================
// Function to compute the inflated map using sliding window
// ===========================================================
void map_inflation_compute(int H, int W, int costmap_in[H][W], float cost_scaling_factor, int inflation_radius, float inscribed_radius, float resolution_map, float inflated_map[H][W]) {
    
    // ------------------------------------------
    // Precompute the inflation kernel
    // ------------------------------------------
    int kernel_size = 2 * inflation_radius + 1; // size of kernel (odd number)
    float kernel[kernel_size][kernel_size];     // 2D array to store precomputed kernel values

    printf("=== Inflation Kernel ===\n");
    // Iterate over kernel offsets from -inflation_radius to +inflation_radius
    for (int dy = -inflation_radius; dy <= inflation_radius; dy++) {
        for (int dx = -inflation_radius; dx <= inflation_radius; dx++) {
            // Compute kernel value at this offset
            kernel[dy + inflation_radius][dx + inflation_radius] = kernel_compute(dx, dy, inflation_radius, cost_scaling_factor, inscribed_radius, resolution_map);
            // Print kernel for visualization
           printf("%6.1f ", kernel[dy + inflation_radius][dx + inflation_radius]);
        }
       printf("\n"); // new line after each row of kernel
    }
   printf("\n");

    // ------------------------------------------
    // Compute inflated map using sliding window
    

    // for (int y = 0; y < H; y++) {
    //     for (int x = 0; x < W; x++) {
    //         if (costmap_in[y][x] == LETHAL_OBSTACLE) {
    //             for (int dy = -inflation_radius; dy <= inflation_radius; dy++) {
    //                 for (int dx = -inflation_radius; dx <= inflation_radius; dx++) {
    //                     int ny = y + dy;
    //                     int nx = x + dx;
    //                     if (nx < 0 || nx >= W || ny < 0 || ny >= H)
    //                         continue;

    //                     float new_cost = kernel[dy + inflation_radius][dx + inflation_radius];
    //                     if (new_cost > inflated_map[ny][nx])
    //                         inflated_map[ny][nx] = new_cost;
    //                 }
    //             }
    //         }
    //     }
    // }


    for (int y = 0; y < H; y++) {             // loop over each row of costmap
        for (int x = 0; x < W; x++) {         // loop over each column of costmap

            float max_cost = (float)costmap_in[y][x]; // initialize max cost with current cell value

            // Slide the kernel window over the neighbors
            for (int dy = -inflation_radius; dy <= inflation_radius; dy++) {
                for (int dx = -inflation_radius; dx <= inflation_radius; dx++) {

                    int ny = y + dy; // neighbor row index
                    int nx = x + dx; // neighbor column index

                    // Skip if neighbor is out of map boundaries
                    if (nx < 0 || nx >= W || ny < 0 || ny >= H) continue;

                    // Only consider neighbor if it is a lethal obstacle
                    if (costmap_in[ny][nx] == LETHAL_OBSTACLE) {
                        // Get the kernel value for this relative position
                        float infl_value = kernel[dy + inflation_radius][dx + inflation_radius];

                        // Update max_cost if this kernel value is higher
                        if (infl_value > max_cost)
                            max_cost = infl_value;
                    }
                }
            }

            // Store the computed max cost in the inflated map
            inflated_map[y][x] = max_cost;
        }
    }
}

// ===========================================================
// Utility function to print an integer map
// ===========================================================
void print_int_map(int H, int W, int map[H][W], const char* title) {
    printf("=== %s ===\n", title);
    // Print from top row to bottom row
    for (int y = H - 1; y >= 0; y--) { 
        for (int x = 0; x < W; x++) {
            // Print 'X' for obstacles
            if (map[y][x] == LETHAL_OBSTACLE)
                printf(" X ");
            else
                printf("%2d ", map[y][x]); // otherwise print numeric cost
        }
        printf("\n");
    }
    printf("\n");
}

// ===========================================================
// Utility function to print a float map
// ===========================================================
void print_float_map(int H, int W, float map[H][W], const char* title) {
    printf("=== %s ===\n", title);
    for (int y = H - 1; y >= 0; y--) { // print top to bottom
        for (int x = 0; x < W; x++) {
            // Print 'X' for high-cost cells (lethal obstacles)
            if (map[y][x] >= LETHAL_OBSTACLE)
                printf(" X ");
            else
                printf("%3.0f ", map[y][x]); // print rounded float value
        }
        printf("\n");
    }
    printf("\n");
}

// ===========================================================
// Main function for testing
// ===========================================================
int main() {
    int H = 10, W = 10;        // height and width of the map
    int costmap[10][10] = {0}; // initialize costmap with zeros

    // Manually set obstacles in the costmap
    costmap[8][3] = LETHAL_OBSTACLE;
    costmap[7][6] = LETHAL_OBSTACLE;
    costmap[5][1] = LETHAL_OBSTACLE;
    costmap[5][8] = LETHAL_OBSTACLE;
    costmap[3][2] = LETHAL_OBSTACLE;
    costmap[3][7] = LETHAL_OBSTACLE;
    costmap[1][4] = LETHAL_OBSTACLE;

    // Parameters for inflation
    float cost_scaling_factor = 3.0; 
    int inflation_radius = 2;
    float inscribed_radius = 0.325;
    float resolution_map = 1.0;

    float inflated_map[H][W]; // store the final inflated map

    // Print the original input costmap
   print_int_map(H, W, costmap, "Input Costmap");

    // Compute inflated map
    map_inflation_compute(H, W, costmap, cost_scaling_factor, inflation_radius, inscribed_radius, resolution_map, inflated_map);

    // Print the final inflated map
   print_float_map(H, W, inflated_map, "Inflated Map");

    return 0;
}

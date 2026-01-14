#include <stdio.h>

#define WIDTH  5
#define HEIGHT 4

// Reconstruct 2D costmap from 1D array
void reconstruct_costmap_2d(
    int width,
    int height,
    const unsigned char *costmap_1d,
    unsigned char costmap_2d[height][width]
) {
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            costmap_2d[y][x] = costmap_1d[y * width + x];
        }
    }
}

// Utility: print costmap
void print_costmap(int width, int height, unsigned char map[height][width]) {
    for (int y = height - 1; y >= 0; y--) {  // top-to-bottom
        for (int x = 0; x < width; x++) {
            printf("%3d ", map[y][x]);
        }
        printf("\n");
    }
}

int main() {
    // Example 1D costmap (row-major)
    unsigned char costmap_1d[WIDTH * HEIGHT] = {
         0,  0,  0,  0,  0,
         0,  0, 50,  0,  0,
         0,  0,  0,  0,  0,
         0,  0,  0,  0,  0
    };

    unsigned char costmap_2d[HEIGHT][WIDTH];

    reconstruct_costmap_2d(WIDTH, HEIGHT, costmap_1d, costmap_2d);

    printf("=== Reconstructed 2D Costmap ===\n");
    print_costmap(WIDTH, HEIGHT, costmap_2d);

    return 0;
}

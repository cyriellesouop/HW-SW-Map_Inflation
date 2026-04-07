#!/usr/bin/env python3
"""
inflate_occupancy_grid.py

Loads an occupancy grid JSON file, adds synthetic obstacles to the
free space, applies pre-processing, runs the kernel-based map
inflation algorithm, normalizes the output to [0, 254], and saves
a side-by-side comparison image.

Pre-processing:
    -1  (Unknown) -> 0   (normalized to free)
     0  (Free)    -> 0
   100  (Lethal)  -> 254 (Costmap2D standard lethal)

Normalization (NOT clamping):
    Each inflated pixel is scaled linearly to [0, 254]:
        normalized = (value / max_value) * 254
    This preserves the cost gradient:
        - cells closest to an obstacle -> highest value (near 254)
        - cells farthest from obstacle -> lowest value (near 0)
        - free cells with no influence -> exactly 0

Usage:
    python inflate_occupancy_grid.py <input.json> <kernel_size> [output.png]

Arguments:
    input.json   : path to JSON file from GlobalMapExtractor
    kernel_size  : odd integer — 3, 5, 7, or 9
    output.png   : (optional) output image  (default: inflation_result_K<size>.png)

Example:
    python inflate_occupancy_grid.py map_data.json 3
    python inflate_occupancy_grid.py map_data.json 5 result_5x5.png

Requirements:
    pip install matplotlib numpy
"""

import sys
import json
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.gridspec import GridSpec

LETHAL = 254


# ------------------------------------------------------------------
# Kernels — symmetric, centre = 254, decreasing outward
# ------------------------------------------------------------------
KERNELS = {
    3: np.array([
        [ 50,  80,  50],
        [ 80, 254,  80],
        [ 50,  80,  50],
    ], dtype=np.uint16),

    5: np.array([
        [ 20,  40,  60,  40,  20],
        [ 40,  80, 120,  80,  40],
        [ 60, 120, 254, 120,  60],
        [ 40,  80, 120,  80,  40],
        [ 20,  40,  60,  40,  20],
    ], dtype=np.uint16),

    7: np.array([
        [ 10,  20,  30,  40,  30,  20,  10],
        [ 20,  40,  60,  80,  60,  40,  20],
        [ 30,  60, 100, 140, 100,  60,  30],
        [ 40,  80, 140, 254, 140,  80,  40],
        [ 30,  60, 100, 140, 100,  60,  30],
        [ 20,  40,  60,  80,  60,  40,  20],
        [ 10,  20,  30,  40,  30,  20,  10],
    ], dtype=np.uint16),

    9: np.array([
        [  5,  10,  15,  20,  25,  20,  15,  10,   5],
        [ 10,  20,  30,  40,  50,  40,  30,  20,  10],
        [ 15,  30,  50,  70,  90,  70,  50,  30,  15],
        [ 20,  40,  70, 110, 150, 110,  70,  40,  20],
        [ 25,  50,  90, 150, 254, 150,  90,  50,  25],
        [ 20,  40,  70, 110, 150, 110,  70,  40,  20],
        [ 15,  30,  50,  70,  90,  70,  50,  30,  15],
        [ 10,  20,  30,  40,  50,  40,  30,  20,  10],
        [  5,  10,  15,  20,  25,  20,  15,  10,   5],
    ], dtype=np.uint16),
}


# ------------------------------------------------------------------
# Load JSON
# ------------------------------------------------------------------
def load_json(filepath):
    with open(filepath, 'r') as f:
        return json.load(f)


# ------------------------------------------------------------------
# Add synthetic obstacles to free cells so that the inflated map
# shows a visible colour gradient across the grid.
# A fixed seed ensures reproducibility.
# ------------------------------------------------------------------
def add_synthetic_obstacles(raw_array, n_extra=800, seed=42):
    arr = raw_array.copy()
    rng = np.random.default_rng(seed)

    free_positions = np.argwhere(arr == 0)
    if len(free_positions) == 0:
        print("  Warning: no free cells available for synthetic obstacles.")
        return arr

    n_extra = min(n_extra, len(free_positions))
    chosen  = rng.choice(len(free_positions), size=n_extra, replace=False)

    for idx in chosen:
        r, c = free_positions[idx]
        arr[r, c] = 100

    print(f"  Synthetic obstacles added : {n_extra:,}")
    print(f"  Total obstacle cells      : "
          f"{int(np.sum(arr == 100)):,}")
    return arr


# ------------------------------------------------------------------
# Pre-processing
#   -1  -> 0    (Unknown normalized to free)
#    0  -> 0    (Free unchanged)
#  100  -> 254  (Lethal remapped to Costmap2D standard)
# ------------------------------------------------------------------
def preprocess(raw_array):
    grid = np.zeros_like(raw_array, dtype=np.uint8)
    grid[raw_array == 100] = LETHAL
    return grid


# ------------------------------------------------------------------
# Obstacle-driven inflation
# For each lethal cell:
#   1. For each neighbour within the kernel radius
#   2. Assign the kernel value at that relative position
#      (this is the inflation cost — not multiplied by patch value,
#       which would be 0 for free cells and kill the gradient)
#   3. Write back using per-cell maximum to handle overlapping zones
# Output is uint16 for consistency with the hardware pipeline.
# ------------------------------------------------------------------
def inflate(grid, kernel):
    height, width = grid.shape
    ksize  = kernel.shape[0]
    radius = ksize // 2
    output = np.zeros((height, width), dtype=np.uint16)

    obstacle_positions = np.argwhere(grid == LETHAL)
    print(f"  Obstacle cells         : {len(obstacle_positions):,}")

    for (r, c) in obstacle_positions:
        for di in range(ksize):
            nr = r + di - radius
            if nr < 0 or nr >= height:
                continue
            for dj in range(ksize):
                nc = c + dj - radius
                if nc < 0 or nc >= width:
                    continue
                # assign the kernel cost at this relative position
                # per-cell maximum handles overlapping inflation zones
                cost = kernel[di, dj]
                if cost > output[nr, nc]:
                    output[nr, nc] = cost

    print(f"  Inflated cells         : {int(np.sum(output > 0)):,}")
    print(f"  Max raw value (uint16) : {int(output.max()):,}")
    return output


# ------------------------------------------------------------------
# Normalization — NOT clamping
#
# Scales all non-zero inflated values linearly to [0, 254]:
#
#     normalized[i] = (inflated[i] / max_value) * 254
#
# Key difference from clamping:
#   Clamping  : every value >= threshold becomes 254 (flat top)
#   Normalization: the single highest value becomes 254, all others
#                  are proportionally scaled — the gradient is fully
#                  preserved across the entire cost field.
#
# Result: closer to obstacle = higher value, farther = lower value.
# Free cells (0) stay exactly 0.
# ------------------------------------------------------------------
def normalize(inflated):
    max_val = float(inflated.max())
    if max_val == 0:
        return np.zeros_like(inflated, dtype=np.uint8)

    norm = np.zeros_like(inflated, dtype=np.float32)
    mask = inflated > 0
    norm[mask] = (inflated[mask].astype(np.float32) / max_val) * 254.0

    result = np.round(norm).astype(np.uint8)
    print(f"  Normalized range       : "
          f"[{int(result[mask].min())}, {int(result.max())}]")
    return result


# ------------------------------------------------------------------
# Colour helpers
# ------------------------------------------------------------------
def grid_to_rgb_binary(arr):
    """White = free, black = lethal obstacle."""
    h, w = arr.shape
    rgb  = np.full((h, w, 3), 255, dtype=np.uint8)
    rgb[arr == LETHAL] = [0, 0, 0]
    return rgb


def normalized_to_rgb(arr):
    """
    YlOrRd colour map over [0, 254].
    Free cells (0) forced to white.
    """
    norm   = arr.astype(np.float32) / 254.0
    #rgb255 = (plt.cm.YlOrRd(norm)[:, :, :3] * 255).astype(np.uint8)
    rgb255 = (plt.cm.gray(norm)[:, :, :3] * 255).astype(np.uint8)
    rgb255[arr == 0] = [255, 255, 255]
    return rgb255


# ------------------------------------------------------------------
# Render side-by-side figure and save
# ------------------------------------------------------------------
def render(grid, normalized, meta, kernel_size, output_path):
    width  = meta['width']
    height = meta['height']
    res    = meta['resolution']
    ox     = meta['origin']['x']
    oy     = meta['origin']['y']

    x_min  = ox;       x_max = ox + width  * res
    y_min  = oy;       y_max = oy + height * res
    extent = [x_min, x_max, y_min, y_max]

    fig = plt.figure(figsize=(16, 7), dpi=150)
    gs  = GridSpec(1, 2, figure=fig, wspace=0.08)

    # ---- Left: pre-processed input ----
    ax1 = fig.add_subplot(gs[0])
    ax1.imshow(grid_to_rgb_binary(grid), origin='upper',
               extent=extent, interpolation='nearest')
    ax1.set_title('Pre-processed Input\n(8-bit: 0 = Free, 254 = Lethal)',
                  fontsize=11, fontweight='bold')
    ax1.set_xlabel('X (m)')
    ax1.set_ylabel('Y (m)')

    legend_in = [
        mpatches.Patch(facecolor='white', edgecolor='black',
                       linewidth=0.5, label='Free (0)'),
        mpatches.Patch(facecolor='black', label='Lethal (254)'),
    ]
    ax1.legend(handles=legend_in, loc='upper right',
               fontsize=8, framealpha=0.9)

    ax1.text(x_min + 0.15, y_max - 0.25,
             f'Lethal cells : {int(np.sum(grid == LETHAL)):,}\n'
             f'Free cells   : {int(np.sum(grid == 0)):,}',
             fontsize=7, va='top',
             bbox=dict(boxstyle='round', facecolor='white', alpha=0.85))

    # ---- Right: normalized inflated output ----
    ax2 = fig.add_subplot(gs[1])
    ax2.imshow(normalized_to_rgb(normalized), origin='upper',
               extent=extent, interpolation='nearest')
    ax2.set_title(
        f'Normalized Inflated Output\n'
        f'({kernel_size}×{kernel_size} kernel | normalized to [0, 254] | no clamping)',
        fontsize=11, fontweight='bold'
    )
    ax2.set_xlabel('X (m)')

    sm = plt.cm.ScalarMappable(
        cmap='YlOrRd',
        norm=plt.Normalize(vmin=0, vmax=254)
    )
    sm.set_array([])
    cbar = fig.colorbar(sm, ax=ax2, fraction=0.046, pad=0.04)
    cbar.set_label('Normalized inflation cost [0 – 254]', fontsize=8)

    legend_out = [
        mpatches.Patch(facecolor='white', edgecolor='grey',
                       linewidth=0.5,     label='Free (0)'),
        mpatches.Patch(facecolor='#FFFF00', label='Low cost — far from obstacle'),
        mpatches.Patch(facecolor='#FF6600', label='Medium cost'),
        mpatches.Patch(facecolor='#CC0000', label='High cost — close to obstacle'),
    ]
    ax2.legend(handles=legend_out, loc='upper right',
               fontsize=8, framealpha=0.9)

    ax2.text(x_min + 0.15, y_max - 0.25,
             f'Inflated cells : {int(np.sum(normalized > 0)):,}\n'
             f'Max cost       : {int(normalized.max())}  (= 254)',
             fontsize=7, va='top',
             bbox=dict(boxstyle='round', facecolor='white', alpha=0.85))

    fig.suptitle(
        f'Map Inflation  —  {width}×{height} grid  |  '
        f'res = {res:.3f} m/cell  |  kernel {kernel_size}×{kernel_size}',
        fontsize=12, fontweight='bold', y=1.01
    )

    plt.savefig(output_path, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"  Image saved to         : {output_path}")


# ------------------------------------------------------------------
# Main
# ------------------------------------------------------------------
def main():
    if len(sys.argv) < 3:
        print("Usage: python inflate_occupancy_grid.py "
              "<input.json> <kernel_size> [output.png]")
        print("  kernel_size : 3, 5, 7, or 9")
        print("Examples:")
        print("  python inflate_occupancy_grid.py map_data.json 3")
        print("  python inflate_occupancy_grid.py map_data.json 5 result_5x5.png")
        sys.exit(1)

    input_path  = sys.argv[1]
    kernel_size = int(sys.argv[2])

    if kernel_size not in KERNELS:
        print(f"Error: kernel_size must be one of {list(KERNELS.keys())}")
        sys.exit(1)

    output_path = (sys.argv[3] if len(sys.argv) > 3
                   else f"inflation_result_K{kernel_size}.png")

    kernel = KERNELS[kernel_size]

    print(f"\n[1/5] Loading {input_path} ...")
    data = load_json(input_path)
    meta = data['metadata']
    raw  = np.array(data['grid_data'], dtype=np.int16)
    print(f"  Grid size     : {meta['width']} x {meta['height']} cells")
    print(f"  Resolution    : {meta['resolution']:.4f} m/cell")
    print(f"  Kernel        : {kernel_size}×{kernel_size}")

    print("\n[2/5] Adding synthetic obstacles ...")
    raw_enriched = add_synthetic_obstacles(raw, n_extra=800, seed=42)

    print("\n[3/5] Pre-processing ...")
    grid = preprocess(raw_enriched)
    print(f"  Unique values : {np.unique(grid).tolist()}")

    print("\n[4/5] Inflating ...")
    inflated = inflate(grid, kernel)

    print("\n[5/5] Normalizing and rendering ...")
    normalized = normalize(inflated)
    render(grid, normalized, meta, kernel_size, output_path)

    print("\nDone.\n")


if __name__ == '__main__':
    main()

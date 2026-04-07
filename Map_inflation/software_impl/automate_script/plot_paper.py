"""
plot_paper.py
-------------
Publication-quality figure: Execution Time only.
Raster-Scan vs Obstacle-Driven for kernel sizes k=3, 5, 7.

Color   = kernel size  (reuses the operations palette for consistency)
            k=3  →  blue   (#1A6FBF)  — same color as Multiplications
            k=5  →  green  (#27AE60)  — same color as Additions
            k=7  →  orange (#D35400)  — same color as Comparisons

Line style = algorithm
            Raster-Scan     →  solid   (─────)
            Obstacle-Driven →  dashed  (- - -)

Output: paper_plot_<RESOLUTION>.pdf  +  .png  (300 dpi)

CSVs expected:
    scalability_256x256_k3.csv
    scalability_256x256_k5.csv
    scalability_256x256_k7.csv
    (same for 512x512 and 1024x1024)
"""

import os
import pandas as pd
import matplotlib
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
from matplotlib.lines import Line2D

# ──────────────────────────────────────────────────────────────────
# ① Configuration
# ──────────────────────────────────────────────────────────────────
RESOLUTION   = "512x512"      # change to "512x512" or "1024x1024"
DATA_DIR     = "."
KERNEL_SIZES = [3]

# ──────────────────────────────────────────────────────────────────
# Publication rcParams
# ──────────────────────────────────────────────────────────────────
matplotlib.rcParams.update({
    "font.family":        "serif",
    "font.serif":         ["Times New Roman", "DejaVu Serif"],
    "font.size":          11,
    "axes.titlesize":     11,
    "axes.labelsize":     11,
    "xtick.labelsize":    10,
    "ytick.labelsize":    10,
    "legend.fontsize":    9.5,
    "figure.dpi":         150,
    "axes.linewidth":     0.8,
    "grid.linewidth":     0.4,
    "lines.linewidth":    1.8,
    "lines.markersize":   5,
    "pdf.fonttype":       42,   # embed fonts — IEEE/ACM requirement
    "ps.fonttype":        42,
})

# ──────────────────────────────────────────────────────────────────
# Color per kernel size — reuses the operations palette so both
# figures in the paper share the same color language.
#   k=3  →  blue   (Multiplications color)
#   k=5  →  green  (Additions color)
#   k=7  →  orange (Comparisons color)
# ──────────────────────────────────────────────────────────────────
KERNEL_STYLE = {
    3: dict(color="#1A6FBF", marker="o"),   # blue   — Multiplications
    5: dict(color="#27AE60", marker="s"),   # green  — Additions
    7: dict(color="#D35400", marker="^"),   # orange — Comparisons
}

# Algorithm line styles
LS_RASTER   = "-"    # solid
LS_OBSTACLE = "--"   # dashed

# ──────────────────────────────────────────────────────────────────
# Load CSV
# ──────────────────────────────────────────────────────────────────
def load_csv(resolution, ksize):
    fname = os.path.join(DATA_DIR, f"scalability_{resolution}_k{ksize}.csv")
    if not os.path.exists(fname):
        print(f"  [WARNING] File not found — skipping: {fname}")
        return None
    df = pd.read_csv(fname)
    df.columns = df.columns.str.strip()
    return df.sort_values("obstacle_density_pct")

# ──────────────────────────────────────────────────────────────────
# Build figure
# ──────────────────────────────────────────────────────────────────
fig, ax = plt.subplots(figsize=(6.5, 4.2))   # IEEE single-column width

ax.set_title(
    f"Execution Time: Raster-Scan vs. Obstacle-Driven — {RESOLUTION} Map",
    pad=8,
)
ax.set_xlabel("Obstacle Density (%)")
ax.set_ylabel("Execution Time (ms)")

for k in KERNEL_SIZES:
    df = load_csv(RESOLUTION, k)
    if df is None:
        continue

    x   = df["obstacle_density_pct"]
    sty = KERNEL_STYLE[k]

    # ── Raster-Scan (solid) ───────────────────────────────────────
    ax.plot(
        x, df["raster_ms"],
        color     = sty["color"],
        linestyle = LS_RASTER,
        marker    = sty["marker"],
        markevery = 6,
        linewidth = 1.8,
        markersize= 5,
    )

    # ── Obstacle-Driven (dashed) ──────────────────────────────────
    ax.plot(
        x, df["obstacle_driven_ms"],
        color     = sty["color"],
        linestyle = LS_OBSTACLE,
        marker    = sty["marker"],
        markevery = 6,
        linewidth = 1.8,
        markersize= 5,
    )

# ──────────────────────────────────────────────────────────────────
# Legend — two sections
#   Section A : line style → algorithm
#   Section B : color      → kernel size
# ──────────────────────────────────────────────────────────────────
section_a = [
    Line2D([0],[0], color="black", linestyle=LS_RASTER,
           linewidth=1.8, label="Raster-Scan"),
    Line2D([0],[0], color="black", linestyle=LS_OBSTACLE,
           linewidth=1.8, label="Obstacle-Driven"),
]

section_b = [
    Line2D([0],[0],
           color     = KERNEL_STYLE[k]["color"],
           linestyle = "-",
           marker    = KERNEL_STYLE[k]["marker"],
           markersize= 5,
           linewidth = 3,
           label     = f"k = {k}×{k}")
    for k in KERNEL_SIZES
]

ax.legend(
    handles       = section_a + section_b,
    loc           = "upper left",
    framealpha    = 0.92,
    edgecolor     = "#cccccc",
    ncol          = 2,
    columnspacing = 1.0,
    handlelength  = 2.0,
)

# ──────────────────────────────────────────────────────────────────
# Grid and axis limits
# ──────────────────────────────────────────────────────────────────
ax.grid(True, linestyle=":", linewidth=0.5, alpha=0.6, which="both")
ax.set_xlim(left=0)
ax.set_ylim(bottom=0)
ax.xaxis.set_minor_locator(ticker.AutoMinorLocator())
ax.yaxis.set_minor_locator(ticker.AutoMinorLocator())

# ──────────────────────────────────────────────────────────────────
# Annotation — key insight on the raster-scan flat line
# Adjust xy to sit on one of your flat raster curves
# ──────────────────────────────────────────────────────────────────
ax.annotate(
    "Raster-scan time\nindependent of density",
    xy         = (10, 0),        # ← point this at your flat raster curve
    xytext     = (15, 30),
    fontsize   = 8.5,
    color      = "#555555",
    arrowprops = dict(arrowstyle="->", color="#555555", lw=1.0),
)

plt.tight_layout(pad=0.8)

# ──────────────────────────────────────────────────────────────────
# Save
# ──────────────────────────────────────────────────────────────────
base = f"paper_plot_{RESOLUTION}"
fig.savefig(f"{base}.pdf", format="pdf", bbox_inches="tight")
fig.savefig(f"{base}.png", format="png", dpi=300, bbox_inches="tight")
print(f"Saved: {base}.pdf  and  {base}.png")

plt.show()

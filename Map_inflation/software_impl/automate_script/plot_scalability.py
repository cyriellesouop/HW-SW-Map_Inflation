"""
plot_scalability.py
-------------------
Plots raster-scan execution time vs obstacle density
for kernel sizes 3, 5, 7 across three map resolutions.

Expected CSV filenames (one per kernel x resolution combo):
    scalability_256x256_k3.csv
    scalability_256x256_k5.csv
    scalability_256x256_k7.csv
    scalability_512x512_k3.csv
    ... etc.

Each CSV must contain at least these columns:
    obstacle_density_pct, raster_ms, obstacle_driven_ms
"""

import os
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker

# ------------------------------------------------------------------
# Configuration — edit paths here if your files live elsewhere
# ------------------------------------------------------------------
RESOLUTIONS  = ["256x256", "512x512", "1024x1024"]
KERNEL_SIZES = [3, 5, 7]
DATA_DIR     = "."          # folder where your CSV files live

# Visual style per kernel size
KERNEL_STYLE = {
    3: dict(color="#2196F3", marker="o", linestyle="-",  label="Kernel 3×3"),
    5: dict(color="#FF5722", marker="s", linestyle="--", label="Kernel 5×5"),
    7: dict(color="#4CAF50", marker="^", linestyle="-.", label="Kernel 7×7"),
}

# ------------------------------------------------------------------
# Helper: load one CSV safely
# ------------------------------------------------------------------
def load_csv(resolution, ksize):
    fname = os.path.join(DATA_DIR,
                         f"scalability_{resolution}_k{ksize}.csv")
    if not os.path.exists(fname):
        print(f"  [WARNING] File not found: {fname}")
        return None
    df = pd.read_csv(fname)
    df.columns = df.columns.str.strip()          # remove stray spaces
    df = df.sort_values("obstacle_density_pct")  # ensure x is ordered
    return df

# ------------------------------------------------------------------
# Figure 1 — Raster-scan time vs density (3 curves per resolution)
#            One subplot per resolution, arranged in a row
# ------------------------------------------------------------------
fig1, axes1 = plt.subplots(1, 3, figsize=(16, 5), sharey=False)
fig1.suptitle("Raster-Scan Execution Time vs Obstacle Density\n"
              "(each subplot = one resolution, curves = kernel size)",
              fontsize=13, fontweight="bold")

for ax, res in zip(axes1, RESOLUTIONS):
    for k in KERNEL_SIZES:
        df = load_csv(res, k)
        if df is None:
            continue
        s = KERNEL_STYLE[k]
        ax.plot(df["obstacle_density_pct"], df["raster_ms"],
                color=s["color"], marker=s["marker"],
                linestyle=s["linestyle"], label=s["label"],
                linewidth=1.8, markersize=4, markevery=5)

    ax.set_title(f"Resolution {res}", fontsize=11)
    ax.set_xlabel("Obstacle Density (%)", fontsize=10)
    ax.set_ylabel("Raster-Scan Time (ms)", fontsize=10)
    ax.legend(fontsize=9)
    ax.grid(True, linestyle="--", alpha=0.5)
    ax.xaxis.set_major_formatter(ticker.FormatStrFormatter("%.1f"))

plt.tight_layout()
fig1.savefig("plot_raster_vs_density.png", dpi=150, bbox_inches="tight")
print("Saved: plot_raster_vs_density.png")

# ------------------------------------------------------------------
# Figure 2 — Obstacle-driven time vs density (same layout)
#            Shows that obstacle-driven DOES scale with density
# ------------------------------------------------------------------
fig2, axes2 = plt.subplots(1, 3, figsize=(16, 5), sharey=False)
fig2.suptitle("Obstacle-Driven Execution Time vs Obstacle Density\n"
              "(each subplot = one resolution, curves = kernel size)",
              fontsize=13, fontweight="bold")

for ax, res in zip(axes2, RESOLUTIONS):
    for k in KERNEL_SIZES:
        df = load_csv(res, k)
        if df is None:
            continue
        s = KERNEL_STYLE[k]
        ax.plot(df["obstacle_density_pct"], df["obstacle_driven_ms"],
                color=s["color"], marker=s["marker"],
                linestyle=s["linestyle"], label=s["label"],
                linewidth=1.8, markersize=4, markevery=5)

    ax.set_title(f"Resolution {res}", fontsize=11)
    ax.set_xlabel("Obstacle Density (%)", fontsize=10)
    ax.set_ylabel("Obstacle-Driven Time (ms)", fontsize=10)
    ax.legend(fontsize=9)
    ax.grid(True, linestyle="--", alpha=0.5)

plt.tight_layout()
fig2.savefig("plot_obstacle_driven_vs_density.png", dpi=150, bbox_inches="tight")
print("Saved: plot_obstacle_driven_vs_density.png")

# ------------------------------------------------------------------
# Figure 3 — Side-by-side comparison on ONE resolution
#            Left:  raster_ms  (flat — bad)
#            Right: obstacle_driven_ms  (linear — expected)
#            Choose your resolution of interest here:
# ------------------------------------------------------------------
COMPARE_RES = "512x512"

fig3, (ax_l, ax_r) = plt.subplots(1, 2, figsize=(13, 5))
fig3.suptitle(f"Raster-Scan vs Obstacle-Driven — Resolution {COMPARE_RES}",
              fontsize=13, fontweight="bold")

for k in KERNEL_SIZES:
    df = load_csv(COMPARE_RES, k)
    if df is None:
        continue
    s = KERNEL_STYLE[k]
    x = df["obstacle_density_pct"]

    ax_l.plot(x, df["raster_ms"],
              color=s["color"], marker=s["marker"],
              linestyle=s["linestyle"], label=s["label"],
              linewidth=1.8, markersize=4, markevery=5)

    ax_r.plot(x, df["obstacle_driven_ms"],
              color=s["color"], marker=s["marker"],
              linestyle=s["linestyle"], label=s["label"],
              linewidth=1.8, markersize=4, markevery=5)

ax_l.set_title("Raster-Scan\n(time independent of density → scalability problem)",
               fontsize=10)
ax_l.set_xlabel("Obstacle Density (%)", fontsize=10)
ax_l.set_ylabel("Execution Time (ms)", fontsize=10)
ax_l.legend(fontsize=9)
ax_l.grid(True, linestyle="--", alpha=0.5)

ax_r.set_title("Obstacle-Driven\n(time grows with density → expected behaviour)",
               fontsize=10)
ax_r.set_xlabel("Obstacle Density (%)", fontsize=10)
ax_r.set_ylabel("Execution Time (ms)", fontsize=10)
ax_r.legend(fontsize=9)
ax_r.grid(True, linestyle="--", alpha=0.5)

plt.tight_layout()
fig3.savefig("plot_comparison.png", dpi=150, bbox_inches="tight")
print("Saved: plot_comparison.png")

plt.show()
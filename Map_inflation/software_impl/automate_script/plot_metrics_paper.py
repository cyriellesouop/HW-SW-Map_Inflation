"""
plot_metrics_paper.py
---------------------
Publication-quality figure for IEEE/ACM paper.

One figure per CSV. All 4 metrics on the same axes:
  Left  Y-axis : Execution Time (ms)
  Right Y-axis : Operation counts (muls, additions, comparisons)

Color   = metric identity  (same color regardless of algorithm)
Line    = algorithm        (solid = Raster-Scan, dashed = Obstacle-Driven)
Marker  = algorithm        (circle = Raster-Scan, square = Obstacle-Driven)

Usage:
    python plot_metrics_paper.py
"""

import os
import pandas as pd
import matplotlib
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
from matplotlib.lines import Line2D

# ─────────────────────────────────────────────────────────────────
# ① Your CSV files — one entry = one saved figure
# ─────────────────────────────────────────────────────────────────
DATAFILES = [
    "opcounts_512x512_k3_step200.csv",
    "opcounts_256x256_k3_step200.csv",
    "opcounts_1024x1024_k3_step200.csv",
]

# ─────────────────────────────────────────────────────────────────
# Publication rcParams
# IEEE single-column ≈ 3.5 in, double-column ≈ 7.16 in
# We target double-column here (wider = more readable with 4 metrics)
# ─────────────────────────────────────────────────────────────────
matplotlib.rcParams.update({
    "font.family":        "serif",
    "font.serif":         ["Times New Roman", "DejaVu Serif"],
    "font.size":          11,
    "axes.titlesize":     11,
    "axes.labelsize":     11,
    "xtick.labelsize":    10,
    "ytick.labelsize":    10,
    "legend.fontsize":    9,
    "figure.dpi":         150,
    "axes.linewidth":     0.8,
    "grid.linewidth":     0.4,
    "lines.linewidth":    1.7,
    "lines.markersize":   5,
    "pdf.fonttype":       42,   # embed fonts — IEEE/ACM requirement
    "ps.fonttype":        42,
})

# ─────────────────────────────────────────────────────────────────
# Metric palette  (color = metric, NOT algorithm)
# ─────────────────────────────────────────────────────────────────
METRICS = [
    dict(
        a1_col = "a1_time_ms",
        a2_col = "a2_time_ms",
        color  = "#C0392B",           # deep red
        axis   = "left",
        label  = "Execution time (ms)",
        marker = ("o", "o"),          # (raster, obstacle-driven)
    ),
    dict(
        a1_col = "a1_multiplications",
        a2_col = "a2_multiplications",
        color  = "#1A6FBF",           # steel blue
        axis   = "right",
        label  = "Multiplications",
        marker = ("o", "o"),
    ),
    dict(
        a1_col = "a1_additions",
        a2_col = "a2_additions",
        color  = "#27AE60",           # forest green
        axis   = "right",
        label  = "Additions",
        marker = ("o", "o"),
    ),
    dict(
        a1_col = "a1_comparisons",
        a2_col = "a2_comparisons",
        color  = "#D35400",           # burnt orange
        axis   = "right",
        label  = "Comparisons",
        marker = ("o", "o"),
    ),
]

# Algorithm visual encoding
ALGO = {
    "a1": dict(linestyle="-",   marker="o", label="Raster-Scan"),
    "a2": dict(linestyle="--",  marker="s", label="Obstacle-Driven"),
}

# ─────────────────────────────────────────────────────────────────
def make_figure(csv_path):
    if not os.path.exists(csv_path):
        print(f"[SKIP] File not found: {csv_path}")
        return

    df = pd.read_csv(csv_path)
    df.columns = df.columns.str.strip()
    df = df.sort_values("obstacle_density_pct")

    H     = int(df["H"].iloc[0])
    W     = int(df["W"].iloc[0])
    ksize = int(df["ksize"].iloc[0])
    x     = df["obstacle_density_pct"]

    fig, ax_l = plt.subplots(figsize=(7.16, 4.5))
    ax_r = ax_l.twinx()

    # ── Draw curves ──────────────────────────────────────────────
    for m in METRICS:
        ax = ax_l if m["axis"] == "left" else ax_r

        # Raster-Scan (solid, circle)
        if m["a1_col"] in df.columns:
            ax.plot(
                x, df[m["a1_col"]],
                color     = m["color"],
                linestyle = ALGO["a1"]["linestyle"],
                marker    = ALGO["a1"]["marker"],
                markevery = 7,
                linewidth = 1.7,
                markersize= 5,
            )

        # Obstacle-Driven (dashed, square)
        if m["a2_col"] in df.columns:
            ax.plot(
                x, df[m["a2_col"]],
                color     = m["color"],
                linestyle = ALGO["a2"]["linestyle"],
                marker    = ALGO["a2"]["marker"],
                markevery = 7,
                linewidth = 1.7,
                markersize= 5,
            )

    # ── Axis cosmetics ───────────────────────────────────────────
    ax_l.set_xlabel("Obstacle density (%)")
    ax_l.set_ylabel("Execution time (ms)", color="#C0392B")
    ax_l.tick_params(axis="y", labelcolor="#C0392B")

    ax_r.set_ylabel("Operation count",   color="#333333")
    ax_r.tick_params(axis="y", labelcolor="#333333")

    ax_l.set_xlim(left=0)
    ax_l.set_ylim(bottom=0)
    ax_r.set_ylim(bottom=0)

    ax_l.grid(True, linestyle=":", linewidth=0.5, alpha=0.6, which="major")
    ax_l.set_title(
        f"Raster-Scan vs. Obstacle-Driven — {H}$\\times${W} map, "
        f"{ksize}$\\times${ksize} kernel",
        pad=8,
    )
    ax_l.xaxis.set_minor_locator(ticker.AutoMinorLocator())
    ax_l.yaxis.set_minor_locator(ticker.AutoMinorLocator())

    # ── Legend — two sections ─────────────────────────────────────
    # Section A: algorithm (line style)
    section_a = [
        Line2D([0],[0], color="black", linestyle="-",  linewidth=1.7,
               marker="o", markersize=5, label="Raster-scan (A1)"),
        Line2D([0],[0], color="black", linestyle="--", linewidth=1.7,
               marker="s", markersize=5, label="Obstacle-driven (A2)"),
    ]
    # Section B: metric (color swatch — thick solid line, no marker)
    section_b = [
        Line2D([0],[0], color=m["color"], linestyle="-",
               linewidth=4, label=m["label"])
        for m in METRICS
    ]

    legend = ax_l.legend(
        handles       = section_a + section_b,
        loc           = "upper left",
        framealpha    = 0.95,
        edgecolor     = "#bbbbbb",
        ncol          = 2,
        columnspacing = 1.0,
        handlelength  = 2.0,
        borderpad     = 0.7,
    )

    plt.tight_layout(pad=0.8)

    # ── Save ──────────────────────────────────────────────────────
    base = os.path.splitext(csv_path)[0]
    fig.savefig(f"{base}_paper.pdf", format="pdf", bbox_inches="tight")
    fig.savefig(f"{base}_paper.png", format="png", dpi=300, bbox_inches="tight")
    print(f"Saved:\n  {base}_paper.pdf\n  {base}_paper.png")
    plt.show()

# ─────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    for f in DATAFILES:
        make_figure(f)

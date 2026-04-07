"""
plot_two_panels.py
------------------
Publication-quality two-panel figure for IEEE/ACM paper.

Left  panel : Raster-Scan         — all 4 metrics
Right panel : Obstacle-Driven     — all 4 metrics

Color   = metric  (identical palette in both panels → easy comparison)
Both panels share the same X-axis (obstacle density %).
Each panel has its own dual Y-axis (time left, counts right).

Usage:
    python plot_two_panels.py
Edit DATAFILES to point at your CSVs.
"""

import os
import pandas as pd
import matplotlib
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
from matplotlib.lines import Line2D

# ─────────────────────────────────────────────────────────────────
# ① Your CSV files — one figure produced per CSV
# ─────────────────────────────────────────────────────────────────
DATAFILES = [
   "opcounts_512x512_k3_step500.csv",
]

# ─────────────────────────────────────────────────────────────────
# Publication rcParams  (IEEE double-column = 7.16 in wide)
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
    "pdf.fonttype":       42,
    "ps.fonttype":        42,
})

# ─────────────────────────────────────────────────────────────────
# Metric definitions — same color used in BOTH panels
# ─────────────────────────────────────────────────────────────────
METRICS = [
    dict(
        a1_col = "a1_time_ms",
        a2_col = "a2_time_ms",
        color  = "#C0392B",           # deep red
        axis   = "left",
        label  = "Execution time (ms)",
        ls     = "-",
        marker = "o",
    ),
    dict(
        a1_col = "a1_multiplications",
        a2_col = "a2_multiplications",
        color  = "#1A6FBF",           # steel blue
        axis   = "right",
        label  = "Multiplications",
        ls     = "--",
        marker = "s",
    ),
    dict(
        a1_col = "a1_additions",
        a2_col = "a2_additions",
        color  = "#27AE60",           # forest green
        axis   = "right",
        label  = "Additions",
        ls     = "-.",
        marker = "^",
    ),
    dict(
        a1_col = "a1_comparisons",
        a2_col = "a2_comparisons",
        color  = "#FFD700",           # burnt orange
        axis   = "right",
        label  = "Comparisons",
        ls     = ":",
        marker = "D",
    ),
]

# ─────────────────────────────────────────────────────────────────
# Helper: draw one panel (ax_l + its twin ax_r) for a given algo
# algo_key : "a1" (raster) or "a2" (obstacle-driven)
# ─────────────────────────────────────────────────────────────────
def draw_panel(ax_l, df, algo_key, title):
    ax_r = ax_l.twinx()
    x    = df["obstacle_density_pct"]

    for m in METRICS:
        col = m[f"{algo_key}_col"]
        if col not in df.columns:
            continue
        ax = ax_l if m["axis"] == "left" else ax_r
        ax.plot(
            x, df[col],
            color     = m["color"],
            linestyle = m["ls"],
            marker    = m["marker"],
            markevery = 7,
            linewidth = 1.7,
            markersize= 5,
            label     = m["label"],
        )

    ax_l.set_title(title, pad=7)
    ax_l.set_xlabel("Obstacle density (%)")
    ax_l.set_ylabel("Execution time (ms)", color="#C0392B")
    ax_l.tick_params(axis="y", labelcolor="#C0392B")

    ax_r.set_ylabel("Operation count", color="#444444")
    ax_r.tick_params(axis="y", labelcolor="#444444")

    ax_l.set_xlim(left=0)
    ax_l.set_ylim(bottom=0)
    ax_r.set_ylim(bottom=0)
    ax_l.grid(True, linestyle=":", linewidth=0.5, alpha=0.6)
    ax_l.xaxis.set_minor_locator(ticker.AutoMinorLocator())
    ax_l.yaxis.set_minor_locator(ticker.AutoMinorLocator())

    return ax_r

# ─────────────────────────────────────────────────────────────────
# Shared legend handles (identical for both panels — placed once)
# ─────────────────────────────────────────────────────────────────
def build_legend_handles():
    return [
        Line2D([0],[0], color=m["color"], linestyle=m["ls"],
               marker=m["marker"], markersize=5, linewidth=1.7,
               label=m["label"])
        for m in METRICS
    ]

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

    fig, (ax1, ax2) = plt.subplots(
        1, 2,
        figsize    = (13.0, 4.8),
        sharey     = False,        # panels have independent Y scales
    )

    # ── Left panel: Raster-Scan ───────────────────────────────────
    draw_panel(
        ax1, df, "a1",
        f"Raster-Scan  ·  {H}$\\times${W}, k={ksize}$\\times${ksize}"
    )

    # ── Right panel: Obstacle-Driven ──────────────────────────────
    draw_panel(
        ax2, df, "a2",
        f"Obstacle-Driven  ·  {H}$\\times${W}, k={ksize}$\\times${ksize}"
    )

    # ── Shared legend below both panels ──────────────────────────
    fig.legend(
        handles       = build_legend_handles(),
        loc           = "lower center",
        ncol          = 4,
        framealpha    = 0.95,
        edgecolor     = "#bbbbbb",
        columnspacing = 1.2,
        handlelength  = 2.2,
        bbox_to_anchor= (0.5, -0.05),
    )

    # ── Super-title ───────────────────────────────────────────────
    fig.suptitle(
        "Operation counts and execution time vs. obstacle density",
        fontsize=12, y=1.01
    )

    plt.tight_layout(pad=0.9, rect=[0, 0.08, 1, 1])

    # ── Save ──────────────────────────────────────────────────────
    base = os.path.splitext(csv_path)[0]
    fig.savefig(f"{base}_twopanel.pdf", format="pdf", bbox_inches="tight")
    fig.savefig(f"{base}_twopanel.png", format="png", dpi=300, bbox_inches="tight")
    print(f"Saved:\n  {base}_twopanel.pdf\n  {base}_twopanel.png")
    plt.show()

# ─────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    for f in DATAFILES:
        make_figure(f)

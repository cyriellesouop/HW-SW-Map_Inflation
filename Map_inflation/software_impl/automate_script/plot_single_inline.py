"""
plot_single_inline.py
---------------------
Publication-quality single-axes figure.

All 8 curves on one graph (4 metrics × 2 algorithms).
No legend box — labels are placed directly on each curve:
  - "Raster-scan"      printed at the right end of raster curves
  - "Obstacle-driven"  printed at the right end of obstacle curves

Color   = metric   (same palette as before)
Style   = algorithm (solid = Raster-scan, dashed = Obstacle-driven)
Marker  = metric   (unique per metric for B&W printing)

Usage:
    python plot_single_inline.py
"""

import os
import numpy as np
import pandas as pd
import matplotlib
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
from matplotlib.lines import Line2D

# ─────────────────────────────────────────────────────────────────
# ① Your CSV files
# ─────────────────────────────────────────────────────────────────
DATAFILES = [
    "opcounts_512x512_k3_step500.csv",
]

# ─────────────────────────────────────────────────────────────────
# Publication rcParams
# ─────────────────────────────────────────────────────────────────
matplotlib.rcParams.update({
    "font.family":        "serif",
    "font.serif":         ["Times New Roman", "DejaVu Serif"],
    "font.size":          11,
    "axes.titlesize":     11,
    "axes.labelsize":     11,
    "xtick.labelsize":    10,
    "ytick.labelsize":    10,
    "figure.dpi":         150,
    "axes.linewidth":     0.8,
    "grid.linewidth":     0.4,
    "lines.linewidth":    1.7,
    "lines.markersize":   5,
    "pdf.fonttype":       42,
    "ps.fonttype":        42,
})

# ─────────────────────────────────────────────────────────────────
# Metric definitions
#   ls_a1 / ls_a2  : line styles for raster / obstacle-driven
#   marker         : unique marker per metric (B&W safe)
# ─────────────────────────────────────────────────────────────────
METRICS = [
    dict(
        a1_col = "a1_time_ms",
        a2_col = "a2_time_ms",
        color  = "#C0392B",
        axis   = "left",
        label  = "Exec. time (ms)",
        ls_a1  = "-",
        ls_a2  = "--",
        marker = "o",
    ),
    dict(
        a1_col = "a1_multiplications",
        a2_col = "a2_multiplications",
        color  = "#1A6FBF",
        axis   = "right",
        label  = "Multiplications",
        ls_a1  = "-",
        ls_a2  = "--",
        marker = "s",
    ),
    dict(
        a1_col = "a1_additions",
        a2_col = "a2_additions",
        color  = "#27AE60",
        axis   = "right",
        label  = "Additions",
        ls_a1  = "-",
        ls_a2  = "--",
        marker = "^",
    ),
    dict(
        a1_col = "a1_comparisons",
        a2_col = "a2_comparisons",
        color  = "#FFD700",
        axis   = "right",
        label  = "Comparisons",
        ls_a1  = "-",
        ls_a2  = "--",
        marker = "D",
    ),
]

# ─────────────────────────────────────────────────────────────────
# Inline label placement
#   Places a small text box directly on the curve at x_frac
#   position along the x-axis, with a white background patch
#   so it stays readable over the grid.
# ─────────────────────────────────────────────────────────────────
def label_curve(ax, x_data, y_data, text, color,
                x_frac=0.88, va="bottom", offset_pts=(4, 4)):
    """
    Place `text` on the curve at fractional position x_frac.
    offset_pts : (dx, dy) nudge in points away from the line.
    """
    idx   = int(x_frac * (len(x_data) - 1))
    x_pos = x_data.iloc[idx]
    y_pos = y_data.iloc[idx]

    ax.annotate(
        text,
        xy         = (x_pos, y_pos),
        xytext     = offset_pts,
        textcoords = "offset points",
        fontsize   = 8,
        color      = color,
        va         = va,
        ha         = "left",
        bbox       = dict(
            boxstyle = "round,pad=0.2",
            fc       = "white",
            ec       = color,
            lw       = 0.6,
            alpha    = 0.85,
        ),
    )
def build_legend_handles():
    from matplotlib.lines import Line2D
    
    # 1. Define the Algorithm Style handles (RS vs OD)
    style_legend = [
        Line2D([0], [0], color="gray", linestyle="-", linewidth=1.7,
               label="Raster-scan"),
        Line2D([0], [0], color="gray", linestyle="--", linewidth=1.7,
               label="Obstacle-centric"),
    ]
    
    # 2. Define the Metric handles (Color/Marker swatches)
    color_legend = [
        Line2D([0], [0], color=m["color"], linestyle="-", linewidth=2.5,
               marker=m["marker"], markersize=6, label=m["label"])
        for m in METRICS
    ]
    
    # Combine both to be placed in the figure legend
    return style_legend + color_legend

# ─────────────────────────────────────────────────────────────────
def make_figure(csv_path):
    if not os.path.exists(csv_path):
        print(f"[SKIP] File not found: {csv_path}")
        return

    df = pd.read_csv(csv_path)
    df.columns = df.columns.str.strip()
    df = df.sort_values("obstacle_density_pct").reset_index(drop=True)

    H     = int(df["H"].iloc[0])
    W     = int(df["W"].iloc[0])
    ksize = int(df["ksize"].iloc[0])
    x     = df["obstacle_density_pct"]

    fig, ax_l = plt.subplots(figsize=(7.16, 5.0))
    ax_r = ax_l.twinx()

    # ── Draw all 8 curves ────────────────────────────────────────
    for i, m in enumerate(METRICS):
        ax = ax_l if m["axis"] == "left" else ax_r

        # Stagger inline-label x position so labels don't pile up
        x_frac_a1 = 0.82 + i * 0.03   # raster labels
        x_frac_a2 = 0.60 + i * 0.03   # obstacle labels (earlier)

        # ── Raster-Scan (solid) ───────────────────────────────
        if m["a1_col"] in df.columns:
            line_a1, = ax.plot(
                x, df[m["a1_col"]],
                color     = m["color"],
                linestyle = m["ls_a1"],
                marker    = m["marker"],
                markevery = 7,
                linewidth = 1.7,
                markersize= 5,
            )
            # label_curve(
            #     ax, x, df[m["a1_col"]],
            #     f" ",
            #     #f"RS – {m['label']}",
            #     color    = m["color"],
            #     x_frac   = x_frac_a1,
            #     va       = "bottom",
            #     offset_pts = (4, 5),
            # )

        # ── Obstacle-Driven (dashed) ──────────────────────────
        if m["a2_col"] in df.columns:
            line_a2, = ax.plot(
                x, df[m["a2_col"]],
                color     = m["color"],
                linestyle = m["ls_a2"],
                marker    = m["marker"],
                markevery = 7,
                linewidth = 1.7,
                markersize= 5,
            )
            # label_curve(
            #     ax, x, df[m["a2_col"]],
            #     f" ",
            #     #f"OD – {m['label']}",
            #     color    = m["color"],
            #     x_frac   = x_frac_a2,
            #     va       = "top",
            #     offset_pts = (4, -5),
            # )

    # ── Axis cosmetics ───────────────────────────────────────────
    ax_l.set_xlabel("Obstacle density (%)")
    ax_l.set_ylabel("Execution time (ms)", color="#C0392B")
    ax_l.tick_params(axis="y", labelcolor="#C0392B")
    ax_r.set_ylabel("Operation count",     color="#444444")
    ax_r.tick_params(axis="y", labelcolor="#444444")

    ax_l.set_xlim(left=0)
    ax_l.set_ylim(bottom=0)
    ax_r.set_ylim(bottom=0)
    ax_l.grid(True, linestyle=":", linewidth=0.5, alpha=0.55)
    ax_l.xaxis.set_minor_locator(ticker.AutoMinorLocator())
    ax_l.yaxis.set_minor_locator(ticker.AutoMinorLocator())

    ax_l.set_title(
        f"Raster-Scan vs. Obstacle-centric ·  "
        f"{H}$\\times${W} map, {ksize}$\\times${ksize} kernel",
        pad=8,
    )
    


    # ── Compact style legend (line style only, no metric names) ──
    # The curve labels already carry metric names inline.
    # This legend only clarifies solid = RS, dashed = OD.
    #from matplotlib.lines import Line2D
    #style_legend = [
     #   Line2D([0],[0], color="gray", linestyle="-",  linewidth=1.7,
      #         label="Raster-scan (RS)"),
       # Line2D([0],[0], color="gray", linestyle="--", linewidth=1.7,
        #       label="Obstacle-driven (OD)"),
    #]
    # Color swatch legend for metrics
    #color_legend = [
     #   Line2D([0],[0], color=m["color"], linestyle="-", linewidth=4,
      #         marker=m["marker"], markersize=5, label=m["label"])
       # for m in METRICS
   # ]

    #ax_l.legend(
     #   handles       = style_legend + color_legend,
      #  loc           = "upper left",
       # framealpha    = 0.92,
        #edgecolor     = "#cccccc",
        #ncol          = 2,
        #fontsize      = 8.5,
        #columnspacing = 1.0,
        #handlelength  = 2.0,
    #)
    fig.legend(
        handles       = build_legend_handles(),
        loc           = "lower center",
        ncol          = 3,
        framealpha    = 0.95,
        edgecolor     = "#bbbbbb",
        columnspacing = 1.2,
        handlelength  = 2.2,
        bbox_to_anchor= (0.5, 0.3),
    )

    plt.tight_layout(pad=0.9)

    # ── Save ──────────────────────────────────────────────────────
    base = os.path.splitext(csv_path)[0]

    fig.savefig(f"{base}_single.pdf", format="pdf", bbox_inches="tight")
    fig.savefig(f"{base}_single.png", format="png", dpi=300, bbox_inches="tight")
    print(f"Saved:\n  {base}_single.pdf\n  {base}_single.png")
    plt.show()

# ─────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    for f in DATAFILES:
        make_figure(f)

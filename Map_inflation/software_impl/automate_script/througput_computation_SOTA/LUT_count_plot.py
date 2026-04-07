# ---------------------------------------
# Throughput computation
# ---------------------------------------
def compute_throughput(architecture, **kwargs):
    """
    Compute normalized throughput (ops/s)

    Parameters:
        architecture: "raster" or "systolic"
        kwargs:
            For raster:
                fps, height, width
            For systolic:
                k (outputs per cycle), fmax (Hz)

    Returns:
        throughput in ops/s
    """

    if architecture == "raster":
        fps = kwargs["fps"]
        H = kwargs["height"]
        W = kwargs["width"]
        return fps * H * W

    elif architecture == "systolic":
        k = kwargs["k"]
        fmax = kwargs["fmax"]  # in Hz
        return k * fmax

    else:
        raise ValueError("Unknown architecture type")


# ---------------------------------------
# Energy efficiency computation
# ---------------------------------------
def compute_energy_efficiency(throughput, power):
    """
    Compute energy efficiency (Gops/s/W)

    Parameters:
        throughput: ops/s
        power: Watts

    Returns:
        efficiency in Gops/s/W
    """
    return (throughput / power) / 1e9


# ---------------------------------------
# Main function
# ---------------------------------------
def main():

    print("==== ENERGY EFFICIENCY COMPUTATION ====\n")

    # ----------------------------
    # Brugger (HC-FPGA)
    # ----------------------------
    print("Brugger HC-FPGA")

    T = compute_throughput(
        architecture="raster",
        fps=1901,
        height=1000,
        width=1000
    )
    eta = compute_energy_efficiency(T, 4.0)
    print(f"3x3 -> Throughput: {T:.2e} ops/s | Efficiency: {eta:.2f} Gops/s/W")

    T = compute_throughput(
        architecture="raster",
        fps=1901,
        height=1000,
        width=1000
    )
    eta = compute_energy_efficiency(T, 4.8)
    print(f"7x7 -> Throughput: {T:.2e} ops/s | Efficiency: {eta:.2f} Gops/s/W\n")


    # ----------------------------
    # Mukherjee
    # ----------------------------
    print("Mukherjee")

    T = compute_throughput(
        architecture="raster",
        fps=3004,
        height=256,
        width=256
    )
    eta = compute_energy_efficiency(T, 0.059)
    print(f"3x3 -> Throughput: {T:.2e} ops/s | Efficiency: {eta:.2f} Gops/s/W")

    T = compute_throughput(
        architecture="raster",
        fps=2958,
        height=256,
        width=256
    )
    eta = compute_energy_efficiency(T, 0.102)
    print(f"5x5 -> Throughput: {T:.2e} ops/s | Efficiency: {eta:.2f} Gops/s/W\n")


    # ----------------------------
    # Ours (SPSA)
    # ----------------------------
    print("Ours (SPSA)")

    T = compute_throughput(
        architecture="systolic",
        k=3,
        fmax=289.9e6
    )
    eta = compute_energy_efficiency(T, 0.059)
    print(f"3x3 -> Throughput: {T:.2e} ops/s | Efficiency: {eta:.2f} Gops/s/W")

    T = compute_throughput(
        architecture="systolic",
        k=5,
        fmax=288e6
    )
    eta = compute_energy_efficiency(T, 0.115)
    print(f"5x5 -> Throughput: {T:.2e} ops/s | Efficiency: {eta:.2f} Gops/s/W")

    T = compute_throughput(
        architecture="systolic",
        k=7,
        fmax=244e6
    )
    eta = compute_energy_efficiency(T, 0.160)
    print(f"7x7 -> Throughput: {T:.2e} ops/s | Efficiency: {eta:.2f} Gops/s/W")


# ---------------------------------------
# Run
# ---------------------------------------
if __name__ == "__main__":
    main()

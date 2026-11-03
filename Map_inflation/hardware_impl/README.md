# FPGA Map Inflation Accelerator (3×3 kernel)

## Overview

This folder holds the FPGA accelerator that offloads the element-wise multiply-accumulate step of map inflation from the CPU (see `../software_impl`). Weights and pixels arrive on a 32-bit AXI-Stream input, and 18-bit partial sums leave on an AXI-Stream output.

Target device: Spartan-7 `xc7s50csga324-2`.

---

## Architecture

| Module | Role |
|--------|------|
| `top.v` | Top level: routes the input stream and generates the PE enable |
| `weight_loader.sv` | Captures the 9 kernel weights (3 × 32-bit words) after reset |
| `data_accumulator.sv` | Repacks 32-bit words (4 pixels) into 3-pixel rows |
| `axis_unpack_data.v` | Input FIFOs between the accumulator and the PE array |
| `pe_wrapper.v` | 3 × 3 array of processing elements (`pe.v`) |
| `adder_tree.v` | Sums the 3 products of each PE row, with an output FIFO |
| `crossbar.v` | Sends the 3 row sums out one after another |
| `fifo.v`, `fifo_axis.v` | First-word fall-through FIFO with an AXI-Stream wrapper |

For each 3-pixel row, the accelerator outputs 3 partial sums, one per kernel row.

---

## Simulation

Open the Vivado project and run `tb_top2`, or run `./run2.sh`, which runs `script2.tcl` (simulation, synthesis, place and route; reports go to `synth_place_route/`). Edit the Vivado path in `run2.sh` for your machine.

With weights 1–9 and the three data words in `tb_top2.v`, the expected output is:

```
84 201 318 | 90 216 342 | 96 231 366 | 0 0 0
```

---

## Updates

### Version 2 (November 2026)

- **FIFOs:** first-word fall-through, popping only on `m_tvalid && m_tready`
- **Crossbar:** a slot is freed when it is copied to the output, which removes the duplicated outputs
- **Data accumulator:** accepts one word per cycle and holds each row until it is taken
- **Top:** `s_axis_tready` is combinational
- **Testbench:** streams one word per cycle, advancing only on a handshake


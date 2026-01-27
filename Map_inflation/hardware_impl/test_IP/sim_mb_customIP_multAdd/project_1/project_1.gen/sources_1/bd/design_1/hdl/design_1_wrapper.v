//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2024.2 (lin64) Build 5239630 Fri Nov 08 22:34:34 MST 2024
//Date        : Fri Jan 23 23:48:30 2026
//Host        : audrey-Precision-5520 running 64-bit Ubuntu 22.04.5 LTS
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (clk_100MHz,
    gpio_tri_o,
    rst,
    uart_rxd,
    uart_txd);
  input clk_100MHz;
  output [15:0]gpio_tri_o;
  input rst;
  input uart_rxd;
  output uart_txd;

  wire clk_100MHz;
  wire [15:0]gpio_tri_o;
  wire rst;
  wire uart_rxd;
  wire uart_txd;

  design_1 design_1_i
       (.clk_100MHz(clk_100MHz),
        .gpio_tri_o(gpio_tri_o),
        .rst(rst),
        .uart_rxd(uart_rxd),
        .uart_txd(uart_txd));
endmodule

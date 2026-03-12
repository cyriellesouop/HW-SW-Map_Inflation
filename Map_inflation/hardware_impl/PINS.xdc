set_property PACKAGE_PIN D2 [get_ports {opb[0]}]
set_property PACKAGE_PIN D1 [get_ports {opb[1]}]
set_property PACKAGE_PIN C2 [get_ports {opb[2]}]
set_property PACKAGE_PIN G1 [get_ports {opcode[0]}]
set_property PACKAGE_PIN F2 [get_ports {opcode[1]}]
set_property PACKAGE_PIN A8 [get_ports rstn]
set_property PACKAGE_PIN N15 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports {aluRes7seg[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {aluRes7seg[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {aluRes7seg[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {aluRes7seg[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {aluRes7seg[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {aluRes7seg[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {aluRes7seg[0]}]
set_property SLEW SLOW [get_ports {aluRes7seg[6]}]
set_property SLEW SLOW [get_ports {aluRes7seg[5]}]
set_property SLEW SLOW [get_ports {aluRes7seg[4]}]
set_property SLEW SLOW [get_ports {aluRes7seg[3]}]
set_property SLEW SLOW [get_ports {aluRes7seg[2]}]
set_property SLEW SLOW [get_ports {aluRes7seg[1]}]
set_property SLEW SLOW [get_ports {aluRes7seg[0]}]
set_property DRIVE 12 [get_ports {aluRes7seg[6]}]
set_property DRIVE 12 [get_ports {aluRes7seg[5]}]
set_property DRIVE 12 [get_ports {aluRes7seg[4]}]
set_property DRIVE 12 [get_ports {aluRes7seg[3]}]
set_property DRIVE 12 [get_ports {aluRes7seg[2]}]
set_property DRIVE 12 [get_ports {aluRes7seg[1]}]
set_property DRIVE 12 [get_ports {aluRes7seg[0]}]
set_property PACKAGE_PIN E1 [get_ports {opa[2]}]
set_property PACKAGE_PIN E2 [get_ports {opa[1]}]
set_property PACKAGE_PIN F1 [get_ports {opa[0]}]

set_property PACKAGE_PIN E6 [get_ports {cathode_disp0[0]}]
set_property PACKAGE_PIN B4 [get_ports {cathode_disp0[1]}]
set_property PACKAGE_PIN D5 [get_ports {cathode_disp0[2]}]
set_property PACKAGE_PIN C5 [get_ports {cathode_disp0[3]}]
set_property PACKAGE_PIN C4 [get_ports {cathode_disp0[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {cathode_disp0[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {cathode_disp0[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {cathode_disp0[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {cathode_disp0[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {cathode_disp0[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {cathode_disp0[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {cathode_disp0[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {cathode_disp0[0]}]

set_property PACKAGE_PIN D7 [get_ports {cathode_disp0[4]}]
set_property PACKAGE_PIN D6 [get_ports {cathode_disp0[5]}]
set_property PACKAGE_PIN C4 [get_ports {cathode_disp0[6]}]
set_property PACKAGE_PIN G6 [get_ports {anode_disp0[0]}]
set_property PACKAGE_PIN H6 [get_ports {anode_disp0[1]}]
set_property PACKAGE_PIN C3 [get_ports {anode_disp0[2]}]
set_property PACKAGE_PIN B3 [get_ports {anode_disp0[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {anode_disp0[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {anode_disp0[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {anode_disp0[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {anode_disp0[0]}]
set_property PACKAGE_PIN A8 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports {opa[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {opa[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {opa[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {opb[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {opb[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {opb[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {opcode[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {opcode[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports rst]
set_property DRIVE 12 [get_ports {cathode_disp0[6]}]
set_property DRIVE 12 [get_ports {cathode_disp0[5]}]
set_property DRIVE 12 [get_ports {cathode_disp0[4]}]
set_property DRIVE 12 [get_ports {cathode_disp0[3]}]
set_property DRIVE 12 [get_ports {cathode_disp0[2]}]
set_property DRIVE 12 [get_ports {cathode_disp0[1]}]
set_property DRIVE 12 [get_ports {cathode_disp0[0]}]


set_property IOSTANDARD LVCMOS33 [get_ports rstn]



get_clock_regions -of_objects [get_sites IOB_X0Y26]
startgroup
create_pblock pblock_2
resize_pblock pblock_2 -add CLOCKREGION_X0Y0:CLOCKREGION_X0Y0
add_cells_to_pblock pblock_2 clk_IBUF_BUFG_inst
endgroup
set_property IS_SOFT 1 [get_pblocks pblock_2]
set_property CONTAIN_ROUTING 0 [get_pblocks pblock_2]


startgroup
create_pblock pblock_clk_IBUF_BUFG_inst
resize_pblock pblock_clk_IBUF_BUFG_inst -add {SLICE_X28Y45:SLICE_X65Y74 DSP48_X1Y18:DSP48_X1Y29 RAMB18_X1Y18:RAMB18_X2Y29 RAMB36_X1Y9:RAMB36_X2Y14}
endgroup
set_property IS_SOFT 0 [get_pblocks pblock_clk_IBUF_BUFG_inst]
set_property CONTAIN_ROUTING 0 [get_pblocks pblock_clk_IBUF_BUFG_inst]
startgroup
add_cells_to_pblock pblock_clk_IBUF_BUFG_inst [get_cells [list s_axis_tready_OBUF_inst]] -clear_locs
endgroup
add_cells_to_pblock pblock_clk_IBUF_BUFG_inst [get_cells [list s_axis_tready_r_reg]] -clear_locs

set_property LOC BUFGCTRL_X0Y15 [get_cells clk_IBUF_BUFG_inst]

set_property IOB TRUE [get_cells s_axis_tready_r_reg]

# BUFG constrained separately with LOC (outside pblock)
set_property LOC BUFGCTRL_X0Y15 [get_cells clk_IBUF_BUFG_inst]



create_clock -name clk -period 5 [get_ports clk]

create_generated_clock -name clk_buf -source [get_ports clk] -divide_by 1 [get_pins clk_IBUF_BUFG_inst/O]

set_false_path -from [get_ports rstn]

set_input_delay -clock clk_buf -max 1 [get_ports {s_axis_tdata[*] s_axis_tvalid}]

set_input_delay -clock clk_buf -min 0.2 [get_ports {s_axis_tdata[*] s_axis_tvalid}]

set_input_delay -clock clk_buf -max 1 [get_ports m_axis_tready]

set_input_delay -clock clk_buf -min 0.2 [get_ports m_axis_tready]

set_output_delay -clock clk_buf -max 1 [get_ports {m_axis_tdata[*] m_axis_tvalid}]

set_output_delay -clock clk_buf -min 0.2 [get_ports {m_axis_tdata[*] m_axis_tvalid}]

set_output_delay -clock clk_buf -max 1 [get_ports {s_axis_tready}]

set_output_delay -clock clk_buf -min 0.2 [get_ports {s_axis_tready}]


# Place tdata registers at SLICE_X65, matching Y coordinate of each IOB
set_property LOC SLICE_X65Y17 [get_cells pe_engine/crossbar_inst/m_axis_tdata_reg[0]]  ;# V2 → IOB_X1Y17
set_property LOC SLICE_X65Y16 [get_cells pe_engine/crossbar_inst/m_axis_tdata_reg[1]]  ;# V5 → IOB_X1Y16
set_property LOC SLICE_X65Y15 [get_cells pe_engine/crossbar_inst/m_axis_tdata_reg[2]]  ;# V4 → IOB_X1Y15
set_property LOC SLICE_X65Y14 [get_cells pe_engine/crossbar_inst/m_axis_tdata_reg[3]]  ;# R4 → IOB_X1Y14
set_property LOC SLICE_X65Y13 [get_cells pe_engine/crossbar_inst/m_axis_tdata_reg[4]]  ;# T3 → IOB_X1Y13
set_property LOC SLICE_X65Y12 [get_cells pe_engine/crossbar_inst/m_axis_tdata_reg[5]]  ;# P6 → IOB_X1Y12
set_property LOC SLICE_X65Y11 [get_cells pe_engine/crossbar_inst/m_axis_tdata_reg[6]]  ;# P5 → IOB_X1Y11
set_property LOC SLICE_X65Y10 [get_cells pe_engine/crossbar_inst/m_axis_tdata_reg[7]]  ;# V7 → IOB_X1Y10
set_property LOC SLICE_X65Y9  [get_cells pe_engine/crossbar_inst/m_axis_tdata_reg[8]]  ;# V6 → IOB_X1Y9
set_property LOC SLICE_X65Y8  [get_cells pe_engine/crossbar_inst/m_axis_tdata_reg[9]]  ;# R5 → IOB_X1Y8
set_property LOC SLICE_X65Y7  [get_cells pe_engine/crossbar_inst/m_axis_tdata_reg[10]] ;# T4 → IOB_X1Y7
set_property LOC SLICE_X65Y6  [get_cells pe_engine/crossbar_inst/m_axis_tdata_reg[11]] ;# T6 → IOB_X1Y6
set_property LOC SLICE_X65Y5  [get_cells pe_engine/crossbar_inst/m_axis_tdata_reg[12]] ;# T5 → IOB_X1Y5
set_property LOC SLICE_X65Y4  [get_cells pe_engine/crossbar_inst/m_axis_tdata_reg[13]] ;# R7 → IOB_X1Y4
set_property LOC SLICE_X65Y3  [get_cells pe_engine/crossbar_inst/m_axis_tdata_reg[14]] ;# R6 → IOB_X1Y3
set_property LOC SLICE_X65Y2  [get_cells pe_engine/crossbar_inst/m_axis_tdata_reg[15]] ;# U7 → IOB_X1Y2
set_property LOC SLICE_X65Y1  [get_cells pe_engine/crossbar_inst/m_axis_tdata_reg[16]] ;# U6 → IOB_X1Y1
set_property LOC SLICE_X65Y0  [get_cells pe_engine/crossbar_inst/m_axis_tdata_reg[17]] ;# P7 → IOB_X1Y0

# Also remove IOB TRUE from these registers
set_property IOB FALSE [get_cells pe_engine/crossbar_inst/m_axis_tdata_reg[*]]

# Lock placed cells so phys_opt cannot move them
set_property IS_LOC_FIXED true [get_cells pe_engine/crossbar_inst/m_axis_tdata_reg[*]]
set_property IS_BEL_FIXED true [get_cells pe_engine/crossbar_inst/m_axis_tdata_reg[*]





# -------------------------------------------------------
# m_axis_tdata: reassign pins to bank 15 (left side, near BUFG)
# Register → SLICE_X0Yn (adjacent to IOB) → IOB_X0Yn → package pin
# -------------------------------------------------------

# m_axis_tdata[0] → SLICE_X0Y50 → IOB_X0Y50 → K13
set_property PACKAGE_PIN K13 [get_ports {m_axis_tdata[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {m_axis_tdata[0]}]
set_property LOC SLICE_X0Y50 [get_cells {pe_engine/crossbar_inst/m_axis_tdata_reg[0]}]

# m_axis_tdata[1] → SLICE_X0Y51 → IOB_X0Y51 → J14
set_property PACKAGE_PIN J14 [get_ports {m_axis_tdata[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {m_axis_tdata[1]}]
set_property LOC SLICE_X0Y51 [get_cells {pe_engine/crossbar_inst/m_axis_tdata_reg[1]}]

# m_axis_tdata[2] → SLICE_X0Y52 → IOB_X0Y52 → J13
set_property PACKAGE_PIN J13 [get_ports {m_axis_tdata[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {m_axis_tdata[2]}]
set_property LOC SLICE_X0Y52 [get_cells {pe_engine/crossbar_inst/m_axis_tdata_reg[2]}]

# m_axis_tdata[3] → SLICE_X0Y53 → IOB_X0Y53 → J15
set_property PACKAGE_PIN J15 [get_ports {m_axis_tdata[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {m_axis_tdata[3]}]
set_property LOC SLICE_X0Y53 [get_cells {pe_engine/crossbar_inst/m_axis_tdata_reg[3]}]

# m_axis_tdata[4] → SLICE_X0Y54 → IOB_X0Y54 → K14
set_property PACKAGE_PIN K14 [get_ports {m_axis_tdata[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {m_axis_tdata[4]}]
set_property LOC SLICE_X0Y54 [get_cells {pe_engine/crossbar_inst/m_axis_tdata_reg[4]}]

# m_axis_tdata[5] → SLICE_X0Y55 → IOB_X0Y55 → H17
set_property PACKAGE_PIN H17 [get_ports {m_axis_tdata[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {m_axis_tdata[5]}]
set_property LOC SLICE_X0Y55 [get_cells {pe_engine/crossbar_inst/m_axis_tdata_reg[5]}]

# m_axis_tdata[6] → SLICE_X0Y56 → IOB_X0Y56 → H16
set_property PACKAGE_PIN H16 [get_ports {m_axis_tdata[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {m_axis_tdata[6]}]
set_property LOC SLICE_X0Y56 [get_cells {pe_engine/crossbar_inst/m_axis_tdata_reg[6]}]

# m_axis_tdata[7] → SLICE_X0Y57 → IOB_X0Y57 → G18
set_property PACKAGE_PIN G18 [get_ports {m_axis_tdata[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {m_axis_tdata[7]}]
set_property LOC SLICE_X0Y57 [get_cells {pe_engine/crossbar_inst/m_axis_tdata_reg[7]}]

# m_axis_tdata[8] → SLICE_X0Y58 → IOB_X0Y58 → H18
set_property PACKAGE_PIN H18 [get_ports {m_axis_tdata[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {m_axis_tdata[8]}]
set_property LOC SLICE_X0Y58 [get_cells {pe_engine/crossbar_inst/m_axis_tdata_reg[8]}]

# m_axis_tdata[9] → SLICE_X0Y59 → IOB_X0Y59 → H14
set_property PACKAGE_PIN H14 [get_ports {m_axis_tdata[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {m_axis_tdata[9]}]
set_property LOC SLICE_X0Y59 [get_cells {pe_engine/crossbar_inst/m_axis_tdata_reg[9]}]

# m_axis_tdata[10] → SLICE_X0Y60 → IOB_X0Y60 → H13
set_property PACKAGE_PIN H13 [get_ports {m_axis_tdata[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {m_axis_tdata[10]}]
set_property LOC SLICE_X0Y60 [get_cells {pe_engine/crossbar_inst/m_axis_tdata_reg[10]}]

# m_axis_tdata[11] → SLICE_X0Y61 → IOB_X0Y61 → J16
set_property PACKAGE_PIN J16 [get_ports {m_axis_tdata[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {m_axis_tdata[11]}]
set_property LOC SLICE_X0Y61 [get_cells {pe_engine/crossbar_inst/m_axis_tdata_reg[11]}]

# m_axis_tdata[12] → SLICE_X0Y62 → IOB_X0Y62 → K16
set_property PACKAGE_PIN K16 [get_ports {m_axis_tdata[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {m_axis_tdata[12]}]
set_property LOC SLICE_X0Y62 [get_cells {pe_engine/crossbar_inst/m_axis_tdata_reg[12]}]

# m_axis_tdata[13] → SLICE_X0Y63 → IOB_X0Y63 → G15
set_property PACKAGE_PIN G15 [get_ports {m_axis_tdata[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {m_axis_tdata[13]}]
set_property LOC SLICE_X0Y63 [get_cells {pe_engine/crossbar_inst/m_axis_tdata_reg[13]}]

# m_axis_tdata[14] → SLICE_X0Y64 → IOB_X0Y64 → H15
set_property PACKAGE_PIN H15 [get_ports {m_axis_tdata[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {m_axis_tdata[14]}]
set_property LOC SLICE_X0Y64 [get_cells {pe_engine/crossbar_inst/m_axis_tdata_reg[14]}]

# m_axis_tdata[15] → SLICE_X0Y65 → IOB_X0Y65 → E13
set_property PACKAGE_PIN E13 [get_ports {m_axis_tdata[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {m_axis_tdata[15]}]
set_property LOC SLICE_X0Y65 [get_cells {pe_engine/crossbar_inst/m_axis_tdata_reg[15]}]

# m_axis_tdata[16] → SLICE_X0Y66 → IOB_X0Y66 → F13
set_property PACKAGE_PIN F13 [get_ports {m_axis_tdata[16]}]
set_property IOSTANDARD LVCMOS33 [get_ports {m_axis_tdata[16]}]
set_property LOC SLICE_X0Y66 [get_cells {pe_engine/crossbar_inst/m_axis_tdata_reg[16]}]

# m_axis_tdata[17] → SLICE_X0Y67 → IOB_X0Y67 → E18
set_property PACKAGE_PIN E18 [get_ports {m_axis_tdata[17]}]
set_property IOSTANDARD LVCMOS33 [get_ports {m_axis_tdata[17]}]
set_property LOC SLICE_X0Y67 [get_cells {pe_engine/crossbar_inst/m_axis_tdata_reg[17]}]

# Lock placement - prevent phys_opt from moving these registers
set_property IS_LOC_FIXED true [get_cells {pe_engine/crossbar_inst/m_axis_tdata_reg[*]}]
set_property IS_BEL_FIXED true [get_cells {pe_engine/crossbar_inst/m_axis_tdata_reg[*]}]
set_property IOB FALSE [get_cells {pe_engine/crossbar_inst/m_axis_tdata_reg[*]}]
#set_false_path -from [get_ports rstn]


# Primary clock on MRCC pin N15 (200 MHz)

create_clock -name clk -period 5 [get_ports clk]
#create_clock -name clk -period 4.0 [get_ports clk]

# Reset is asynchronous - no timing analysis needed
set_false_path -from [get_ports rstn]

set_input_delay -clock clk -max 1 [get_ports {s_axis_tdata[*] s_axis_tvalid}]

set_input_delay -clock clk -min 0.2 [get_ports {s_axis_tdata[*] s_axis_tvalid}]

set_input_delay -clock clk -max 1 [get_ports m_axis_tready]

set_input_delay -clock clk -min 0.2 [get_ports m_axis_tready]

set_output_delay -clock clk -max 1 [get_ports {m_axis_tdata[*] m_axis_tvalid}]

set_output_delay -clock clk -min 0.2 [get_ports {m_axis_tdata[*] m_axis_tvalid}]

set_output_delay -clock clk -max 1 [get_ports {s_axis_tready}]

set_output_delay -clock clk -min 0.2 [get_ports {s_axis_tready}]


create_generated_clock -name clk_buf \
    -source [get_pins mmcm_inst/CLKIN1] \
    -multiply_by 1 \
    [get_pins mmcm_inst/CLKOUT0]









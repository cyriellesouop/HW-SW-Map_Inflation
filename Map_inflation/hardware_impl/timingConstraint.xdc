create_clock -name clk -period 3.45 [get_ports clk]


set_property HD.CLK_SRC BUFGCTRL_X0Y31 [get_ports clk]

set_property HD.PARTPIN_LOCS INT_L_X28Y7 [get_ports rstn]

# Input ports - left edge of pblock SLICE_X0Y1:SLICE_X65Y38 SLICE_X26Y5:SLICE_X29Y13
#set_property HD.PARTPIN_RANGE SLICE_X32Y4:SLICE_X33Y11  [get_ports {s_axis_tdata[*]}]
#set_property HD.PARTPIN_RANGE SLICE_X0Y1:SLICE_X65Y38   [get_ports rstn]
# Output ports - right edge of pblock SLICE_X0Y3:SLICE_X20Y46 




#set_property HD.PARTPIN_RANGE SLICE_X15Y5:SLICE_X29Y13 [get_ports {m_axis_tdata[*]}]


set_property HD.PARTPIN_LOCS INT_R_X11Y10 [get_ports {m_axis_tdata[0]}]
set_property HD.PARTPIN_LOCS INT_R_X11Y11 [get_ports {m_axis_tdata[1]}]
set_property HD.PARTPIN_LOCS INT_R_X11Y10 [get_ports {m_axis_tdata[2]}]
set_property HD.PARTPIN_LOCS INT_R_X11Y9  [get_ports {m_axis_tdata[3]}]
set_property HD.PARTPIN_LOCS INT_R_X11Y10 [get_ports {m_axis_tdata[4]}]
set_property HD.PARTPIN_LOCS INT_R_X11Y9  [get_ports {m_axis_tdata[5]}]
set_property HD.PARTPIN_LOCS INT_R_X11Y12 [get_ports {m_axis_tdata[6]}]
set_property HD.PARTPIN_LOCS INT_R_X11Y12 [get_ports {m_axis_tdata[7]}]
set_property HD.PARTPIN_LOCS INT_R_X11Y12 [get_ports {m_axis_tdata[8]}]
set_property HD.PARTPIN_LOCS INT_R_X11Y13 [get_ports {m_axis_tdata[9]}]
set_property HD.PARTPIN_LOCS INT_R_X11Y11 [get_ports {m_axis_tdata[10]}]
set_property HD.PARTPIN_LOCS INT_R_X11Y9  [get_ports {m_axis_tdata[11]}]
set_property HD.PARTPIN_LOCS INT_R_X11Y12 [get_ports {m_axis_tdata[12]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y9  [get_ports {m_axis_tdata[13]}]
set_property HD.PARTPIN_LOCS INT_R_X11Y13 [get_ports {m_axis_tdata[14]}]
set_property HD.PARTPIN_LOCS INT_R_X11Y13 [get_ports {m_axis_tdata[15]}]
set_property HD.PARTPIN_LOCS INT_R_X11Y12 [get_ports {m_axis_tdata[16]}]
set_property HD.PARTPIN_LOCS INT_R_X11Y13 [get_ports {m_axis_tdata[17]}]

set_property HD.PARTPIN_RANGE SLICE_X0Y1:SLICE_X65Y38 [get_ports m_axis_tvalid]
set_property HD.PARTPIN_RANGE SLICE_X0Y1:SLICE_X65Y38 [get_ports s_axis_tready]

set_property  HD.PARTPIN_LOCS INT_R_X25Y6  [get_ports s_axis_tvalid]
set_property HD.PARTPIN_LOCS INT_R_X29Y3   [get_ports m_axis_tready]


set_property HD.PARTPIN_LOCS INT_R_X21Y9   [get_ports {s_axis_tdata[0]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y9   [get_ports {s_axis_tdata[1]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y7   [get_ports {s_axis_tdata[2]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y8   [get_ports {s_axis_tdata[3]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y10  [get_ports {s_axis_tdata[4]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y10  [get_ports {s_axis_tdata[5]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y11  [get_ports {s_axis_tdata[6]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y11  [get_ports {s_axis_tdata[7]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y9  [get_ports {s_axis_tdata[8]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y9  [get_ports {s_axis_tdata[9]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y7  [get_ports {s_axis_tdata[10]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y8  [get_ports {s_axis_tdata[11]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y10  [get_ports {s_axis_tdata[12]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y9  [get_ports {s_axis_tdata[13]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y10  [get_ports {s_axis_tdata[14]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y10  [get_ports {s_axis_tdata[15]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y6  [get_ports {s_axis_tdata[16]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y6  [get_ports {s_axis_tdata[17]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y5  [get_ports {s_axis_tdata[18]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y5  [get_ports {s_axis_tdata[19]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y6  [get_ports {s_axis_tdata[20]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y6  [get_ports {s_axis_tdata[21]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y7  [get_ports {s_axis_tdata[22]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y7  [get_ports {s_axis_tdata[23]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y4  [get_ports {s_axis_tdata[24]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y5  [get_ports {s_axis_tdata[25]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y5  [get_ports {s_axis_tdata[26]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y4  [get_ports {s_axis_tdata[27]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y5  [get_ports {s_axis_tdata[28]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y4 [get_ports {s_axis_tdata[29]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y4  [get_ports {s_axis_tdata[30]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y4  [get_ports {s_axis_tdata[31]}]


# Move the Partition Pins to the new Tile
#set_property HD.PARTPIN_LOCS INT_L_X8Y3 [get_ports {s_axis_tdata[28]}]
#set_property HD.PARTPIN_LOCS INT_L_X8Y3 [get_ports {s_axis_tdata[30]}]
#set_property HD.PARTPIN_LOCS INT_L_X8Y3 [get_ports {s_axis_tdata[31]}]


# 1. Store the cell objects
set cell1 [get_cells weight_loader_inst/weight_storage_reg[15]]
set cell2 [get_cells weight_loader_inst/weight_storage_reg[7]]

# 2. Move them to the new Slice while keeping their relative BEL position
# --- Move bits 15 and 7 to SLICE_X30Y11 ---
set my_group1 [get_cells {weight_loader_inst/weight_storage_reg[15] weight_loader_inst/weight_storage_reg[7]}]
set_property LOC SLICE_X30Y11 $my_group1
set_property IS_LOC_FIXED TRUE $my_group1

# --- Move bits 2, 23, 22, 10 to SLICE_X34Y8 ---
set my_group2 [get_cells { \
    weight_loader_inst/weight_storage_reg[2]  \
    weight_loader_inst/weight_storage_reg[23] \
    weight_loader_inst/weight_storage_reg[22] \
    weight_loader_inst/weight_storage_reg[10] \
}]
set_property LOC SLICE_X34Y8 $my_group2
set_property IS_LOC_FIXED TRUE $my_group2




set my_bits [get_cells { \
   accumulator_inst/in_buf_data_reg[21] \
    accumulator_inst/in_buf_data_reg[20] \
    accumulator_inst/in_buf_data_reg[17] \
    accumulator_inst/in_buf_data_reg[16] \
}]

# 2. Assign the Location (Vivado will automatically pick the AFF/BFF/CFF slots)
set_property LOC SLICE_X34Y7 $my_bits
set_property IS_LOC_FIXED TRUE $my_bits











set_input_delay -clock clk 1 [get_ports rstn]

set_input_delay -clock clk 2 [get_ports {s_axis_tdata[*] s_axis_tvalid}]

set_input_delay -clock clk 1 [get_ports m_axis_tready]


set_output_delay -clock clk 1 [get_ports {m_axis_tdata[*] m_axis_tvalid}]

set_output_delay -clock clk 1 [get_ports {s_axis_tready}]





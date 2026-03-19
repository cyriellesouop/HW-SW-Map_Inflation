create_clock -name clk -period 5 [get_ports clk]


set_false_path -from [get_ports rstn]


set_input_delay -clock clk -max 1 [get_ports {s_axis_tdata[*] s_axis_tvalid}]

set_input_delay -clock clk -min 0.2 [get_ports {s_axis_tdata[*] s_axis_tvalid}]


set_input_delay -clock clk -max 1 [get_ports m_axis_tready]

set_input_delay -clock clk -min 0.2 [get_ports m_axis_tready]



set_output_delay -clock clk -max 1 [get_ports {m_axis_tdata[*] m_axis_tvalid}]

set_output_delay -clock clk -min 0.2 [get_ports {m_axis_tdata[*] m_axis_tvalid}]


set_output_delay -clock clk -max 1 [get_ports {s_axis_tready}]

set_output_delay -clock clk -min 0.2 [get_ports {s_axis_tready}]








create_pblock pblock_top
resize_pblock [get_pblocks pblock_top] -add {SLICE_X36Y1:SLICE_X65Y38 DSP48_X1Y2:DSP48_X1Y13 RAMB18_X1Y2:RAMB18_X2Y13 RAMB36_X1Y1:RAMB36_X2Y6 SLICE_X36Y1:SLICE_X65Y38 DSP48_X1Y2:DSP48_X1Y13 RAMB18_X1Y2:RAMB18_X2Y13 RAMB36_X1Y1:RAMB36_X2Y6} -locs keep_all
add_cells_to_pblock [get_pblocks pblock_top] [get_cells [list accumulator_inst] ]
add_cells_to_pblock [get_pblocks pblock_top] [get_cells [list flush_delay_inst] ]
add_cells_to_pblock [get_pblocks pblock_top] [get_cells [list pe_en_delayed_reg ] ]
add_cells_to_pblock [get_pblocks pblock_top] [get_cells [list pe_engine ] ]
add_cells_to_pblock [get_pblocks pblock_top] [get_cells [list s_axis_tready_r_reg ] ]
add_cells_to_pblock [get_pblocks pblock_top] [get_cells [list unpacker ] ]
add_cells_to_pblock [get_pblocks pblock_top] [get_cells [list weight_loader_inst ] ]

set_property HD.PARTPIN_LOCS INT_L_X28Y7 [get_ports rstn]
# Input ports - left edge of pblock SLICE_X0Y1:SLICE_X65Y38 SLICE_X26Y5:SLICE_X29Y13
#set_property HD.PARTPIN_RANGE SLICE_X32Y4:SLICE_X33Y11  [get_ports {s_axis_tdata[*]}]
# Output ports - right edge of pblock SLICE_X0Y3:SLICE_X20Y46 


# Input ports - left edge of pblock SLICE_X0Y1:SLICE_X65Y38 SLICE_X26Y5:SLICE_X29Y13
#set_property HD.PARTPIN_RANGE SLICE_X0Y1:SLICE_X65Y38   [get_ports rstn]
#set_property HD.PARTPIN_RANGE SLICE_X0Y1:SLICE_X65Y38   [get_ports {s_axis_tdata[*]}]
set_property HD.PARTPIN_RANGE SLICE_X0Y1:SLICE_X65Y38   [get_ports s_axis_tvalid]
set_property HD.PARTPIN_RANGE SLICE_X0Y1:SLICE_X65Y38   [get_ports m_axis_tready]

# --- Verified s_axis_tdata Constraints (Column X31) ---
# Mapping 32 bits, 1 bit per tile
set_property HD.PARTPIN_LOCS INT_R_X31Y6  [get_ports {s_axis_tdata[0]}]
set_property HD.PARTPIN_LOCS INT_R_X31Y7  [get_ports {s_axis_tdata[1]}]
set_property HD.PARTPIN_LOCS INT_R_X31Y8  [get_ports {s_axis_tdata[2]}]
set_property HD.PARTPIN_LOCS INT_R_X31Y9  [get_ports {s_axis_tdata[3]}]
set_property HD.PARTPIN_LOCS INT_R_X31Y10 [get_ports {s_axis_tdata[4]}]
set_property HD.PARTPIN_LOCS INT_R_X31Y11 [get_ports {s_axis_tdata[5]}]
set_property HD.PARTPIN_LOCS INT_R_X31Y12 [get_ports {s_axis_tdata[6]}]
set_property HD.PARTPIN_LOCS INT_R_X31Y13 [get_ports {s_axis_tdata[7]}]
set_property HD.PARTPIN_LOCS INT_R_X31Y14 [get_ports {s_axis_tdata[8]}]
set_property HD.PARTPIN_LOCS INT_R_X31Y15 [get_ports {s_axis_tdata[9]}]
set_property HD.PARTPIN_LOCS INT_R_X31Y16 [get_ports {s_axis_tdata[10]}]
set_property HD.PARTPIN_LOCS INT_R_X31Y17 [get_ports {s_axis_tdata[11]}]
set_property HD.PARTPIN_LOCS INT_R_X31Y18 [get_ports {s_axis_tdata[12]}]
set_property HD.PARTPIN_LOCS INT_R_X31Y19 [get_ports {s_axis_tdata[13]}]
set_property HD.PARTPIN_LOCS INT_R_X31Y20 [get_ports {s_axis_tdata[14]}]
set_property HD.PARTPIN_LOCS INT_R_X31Y21 [get_ports {s_axis_tdata[15]}]
set_property HD.PARTPIN_LOCS INT_R_X31Y22 [get_ports {s_axis_tdata[16]}]
set_property HD.PARTPIN_LOCS INT_R_X31Y23 [get_ports {s_axis_tdata[17]}]
set_property HD.PARTPIN_LOCS INT_R_X31Y24 [get_ports {s_axis_tdata[18]}]
set_property HD.PARTPIN_LOCS INT_R_X31Y25 [get_ports {s_axis_tdata[19]}]
set_property HD.PARTPIN_LOCS INT_R_X31Y26 [get_ports {s_axis_tdata[20]}]
set_property HD.PARTPIN_LOCS INT_R_X31Y27 [get_ports {s_axis_tdata[21]}]
set_property HD.PARTPIN_LOCS INT_R_X31Y28 [get_ports {s_axis_tdata[22]}]
set_property HD.PARTPIN_LOCS INT_R_X31Y29 [get_ports {s_axis_tdata[23]}]
set_property HD.PARTPIN_LOCS INT_R_X31Y30 [get_ports {s_axis_tdata[24]}]
set_property HD.PARTPIN_LOCS INT_R_X31Y31 [get_ports {s_axis_tdata[25]}]
set_property HD.PARTPIN_LOCS INT_R_X31Y32 [get_ports {s_axis_tdata[26]}]
set_property HD.PARTPIN_LOCS INT_R_X31Y33 [get_ports {s_axis_tdata[27]}]
set_property HD.PARTPIN_LOCS INT_R_X31Y34 [get_ports {s_axis_tdata[28]}]
set_property HD.PARTPIN_LOCS INT_R_X31Y35 [get_ports {s_axis_tdata[29]}]
set_property HD.PARTPIN_LOCS INT_R_X31Y36 [get_ports {s_axis_tdata[30]}]
set_property HD.PARTPIN_LOCS INT_R_X31Y37 [get_ports {s_axis_tdata[31]}]


# Output ports - right edge of pblock SLICE_X0Y3:SLICE_X20Y46 
set_property HD.PARTPIN_RANGE SLICE_X0Y1:SLICE_X65Y38 [get_ports {m_axis_tdata[*]}]
set_property HD.PARTPIN_RANGE SLICE_X0Y1:SLICE_X65Y38 [get_ports m_axis_tvalid]
set_property HD.PARTPIN_RANGE SLICE_X0Y1:SLICE_X65Y38 [get_ports s_axis_tready]




set_property DONT_TOUCH TRUE [get_ports rstn]
set_property DONT_TOUCH TRUE [get_nets -hier -filter {NAME =~ "*rstn*"}]




set_property PACKAGE_PIN N15 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

set_property PACKAGE_PIN A8 [get_ports rstn]
set_property IOSTANDARD LVCMOS33 [get_ports rstn]

set_property IOB TRUE [get_cells s_axis_tready_r_reg  {pe_engine/crossbar_inst/m_axis_tdata_reg[*]} {pe_engine/crossbar_inst/m_axis_tvalid_reg_rep} ]

set_property IOSTANDARD LVCMOS33 [get_ports {m_axis_tdata[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports m_axis_tvalid]
set_property IOSTANDARD LVCMOS33 [get_ports m_axis_tready]

set_property IOSTANDARD LVCMOS33 [get_ports {s_axis_tdata[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports s_axis_tvalid]
set_property IOSTANDARD LVCMOS33 [get_ports s_axis_tready]

startgroup
create_pblock pblock
#resize_pblock pblock -add {SLICE_X36Y0:SLICE_X65Y43 DSP48_X1Y0:DSP48_X1Y15 RAMB18_X1Y0:RAMB18_X2Y15 RAMB36_X1Y0:RAMB36_X2Y7}
resize_pblock pblock -add {SLICE_X2Y3:SLICE_X31Y46 DSP48_X0Y2:DSP48_X0Y17 RAMB18_X0Y2:RAMB18_X0Y17 RAMB36_X0Y1:RAMB36_X0Y8}
add_cells_to_pblock pblock [get_cells [list weight_loader_inst]] -clear_locs
add_cells_to_pblock pblock [get_cells [list unpacker]] -clear_locs
add_cells_to_pblock pblock [get_cells [list accumulator_inst]] -clear_locs
#add_cells_to_pblock pblock [get_cells [list pe_engine]] -clear_locs
endgroup



set_property HD.PARTPIN_RANGE SLICE_X32Y4:SLICE_X33Y11  [get_ports {s_axis_tdata[*]}]
set_property HD.PARTPIN_RANGE SLICE_X0Y1:SLICE_X65Y38  [get_ports s_axis_tvalid]
set_property HD.PARTPIN_RANGE SLICE_X0Y1:SLICE_X65Y38   [get_ports m_axis_tready]
set_property HD.PARTPIN_RANGE SLICE_X0Y1:SLICE_X65Y38   [get_ports rstn]


# Spreading s_axis_tdata[0:31] across X21 Y4 to Y35
set_property HD.PARTPIN_LOCS INT_R_X21Y4  [get_ports {s_axis_tdata[0]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y5  [get_ports {s_axis_tdata[1]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y6  [get_ports {s_axis_tdata[2]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y7  [get_ports {s_axis_tdata[3]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y8  [get_ports {s_axis_tdata[4]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y9  [get_ports {s_axis_tdata[5]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y10 [get_ports {s_axis_tdata[6]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y11 [get_ports {s_axis_tdata[7]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y12 [get_ports {s_axis_tdata[8]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y13 [get_ports {s_axis_tdata[9]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y14 [get_ports {s_axis_tdata[10]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y15 [get_ports {s_axis_tdata[11]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y16 [get_ports {s_axis_tdata[12]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y17 [get_ports {s_axis_tdata[13]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y18 [get_ports {s_axis_tdata[14]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y19 [get_ports {s_axis_tdata[15]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y20 [get_ports {s_axis_tdata[16]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y21 [get_ports {s_axis_tdata[17]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y22 [get_ports {s_axis_tdata[18]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y23 [get_ports {s_axis_tdata[19]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y24 [get_ports {s_axis_tdata[20]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y25 [get_ports {s_axis_tdata[21]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y26 [get_ports {s_axis_tdata[22]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y27 [get_ports {s_axis_tdata[23]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y28 [get_ports {s_axis_tdata[24]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y29 [get_ports {s_axis_tdata[25]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y30 [get_ports {s_axis_tdata[26]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y31 [get_ports {s_axis_tdata[27]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y32 [get_ports {s_axis_tdata[28]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y33 [get_ports {s_axis_tdata[29]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y34 [get_ports {s_axis_tdata[30]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y35 [get_ports {s_axis_tdata[31]}]




# Output ports - right edge of pblock SLICE_X0Y3:SLICE_X20Y46 
set_property HD.PARTPIN_RANGE SLICE_X26Y5:SLICE_X29Y13 [get_ports {m_axis_tdata[*]}]
set_property HD.PARTPIN_RANGE SLICE_X0Y1:SLICE_X65Y38 [get_ports m_axis_tvalid]
set_property HD.PARTPIN_RANGE SLICE_X0Y1:SLICE_X65Y38 [get_ports s_axis_tready]


set_property HD.PARTPIN_LOCS INT_R_X21Y9   [get_ports {s_axis_tdata[0]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y9   [get_ports {s_axis_tdata[1]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y7   [get_ports {s_axis_tdata[2]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y8   [get_ports {s_axis_tdata[3]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y10   [get_ports {s_axis_tdata[4]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y10   [get_ports {s_axis_tdata[5]}]
set_property HD.PARTPIN_LOCS INT_R_X21Y11   [get_ports {s_axis_tdata[6]}]
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





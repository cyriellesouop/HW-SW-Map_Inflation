
create_clock -name clk -period 5.8 [get_ports clk]
set_property HD.CLK_SRC BUFGCTRL_X0Y31 [get_ports clk]





# DONT_TOUCH on reset


# Input partition pins — INT_L_X24 is the confirmed left edge
set_property HD.PARTPIN_LOCS INT_L_X30Y17 [get_ports rstn]
set_property HD.PARTPIN_LOCS INT_L_X24Y2 [get_ports s_axis_tvalid]
set_property HD.PARTPIN_LOCS INT_L_X24Y3 [get_ports m_axis_tready]

set_property HD.PARTPIN_LOCS INT_L_X24Y4  [get_ports {s_axis_tdata[0]}]
set_property HD.PARTPIN_LOCS INT_L_X24Y5  [get_ports {s_axis_tdata[1]}]
set_property HD.PARTPIN_LOCS INT_L_X24Y6  [get_ports {s_axis_tdata[2]}]
set_property HD.PARTPIN_LOCS INT_L_X24Y7  [get_ports {s_axis_tdata[3]}]
set_property HD.PARTPIN_LOCS INT_L_X24Y8  [get_ports {s_axis_tdata[4]}]
set_property HD.PARTPIN_LOCS INT_L_X24Y9  [get_ports {s_axis_tdata[5]}]
set_property HD.PARTPIN_LOCS INT_L_X24Y10 [get_ports {s_axis_tdata[6]}]
set_property HD.PARTPIN_LOCS INT_L_X24Y11 [get_ports {s_axis_tdata[7]}]
set_property HD.PARTPIN_LOCS INT_L_X24Y12 [get_ports {s_axis_tdata[8]}]
set_property HD.PARTPIN_LOCS INT_L_X24Y13 [get_ports {s_axis_tdata[9]}]
set_property HD.PARTPIN_LOCS INT_L_X24Y14 [get_ports {s_axis_tdata[10]}]
set_property HD.PARTPIN_LOCS INT_L_X24Y15 [get_ports {s_axis_tdata[11]}]
set_property HD.PARTPIN_LOCS INT_L_X24Y16 [get_ports {s_axis_tdata[12]}]
set_property HD.PARTPIN_LOCS INT_L_X24Y17 [get_ports {s_axis_tdata[13]}]
set_property HD.PARTPIN_LOCS INT_L_X24Y18 [get_ports {s_axis_tdata[14]}]
set_property HD.PARTPIN_LOCS INT_L_X24Y19 [get_ports {s_axis_tdata[15]}]
set_property HD.PARTPIN_LOCS INT_L_X24Y20 [get_ports {s_axis_tdata[16]}]
set_property HD.PARTPIN_LOCS INT_L_X24Y21 [get_ports {s_axis_tdata[17]}]
set_property HD.PARTPIN_LOCS INT_L_X24Y22 [get_ports {s_axis_tdata[18]}]
set_property HD.PARTPIN_LOCS INT_L_X24Y23 [get_ports {s_axis_tdata[19]}]
set_property HD.PARTPIN_LOCS INT_L_X24Y24 [get_ports {s_axis_tdata[20]}]
set_property HD.PARTPIN_LOCS INT_L_X24Y25 [get_ports {s_axis_tdata[21]}]
set_property HD.PARTPIN_LOCS INT_L_X24Y26 [get_ports {s_axis_tdata[22]}]
set_property HD.PARTPIN_LOCS INT_L_X24Y27 [get_ports {s_axis_tdata[23]}]
set_property HD.PARTPIN_LOCS INT_L_X24Y28 [get_ports {s_axis_tdata[24]}]
set_property HD.PARTPIN_LOCS INT_L_X24Y29 [get_ports {s_axis_tdata[25]}]
set_property HD.PARTPIN_LOCS INT_L_X24Y30 [get_ports {s_axis_tdata[26]}]
set_property HD.PARTPIN_LOCS INT_L_X24Y31 [get_ports {s_axis_tdata[27]}]
set_property HD.PARTPIN_LOCS INT_L_X24Y32 [get_ports {s_axis_tdata[28]}]
set_property HD.PARTPIN_LOCS INT_L_X24Y33 [get_ports {s_axis_tdata[29]}]
set_property HD.PARTPIN_LOCS INT_L_X24Y34 [get_ports {s_axis_tdata[30]}]
set_property HD.PARTPIN_LOCS INT_L_X24Y35 [get_ports {s_axis_tdata[31]}]


# Output partition pins — use PARTPIN_RANGE on right edge
set_property HD.PARTPIN_RANGE SLICE_X60Y1:SLICE_X65Y38 \
    [get_ports {m_axis_tdata[*]}]
set_property HD.PARTPIN_RANGE SLICE_X60Y1:SLICE_X65Y38 \
    [get_ports m_axis_tvalid]
set_property HD.PARTPIN_RANGE SLICE_X60Y1:SLICE_X65Y38 \
    [get_ports s_axis_tready]



set_input_delay -clock clk 2 [get_ports rstn]

set_input_delay -clock clk 2 [get_ports {s_axis_tdata[*]}]

set_input_delay -clock clk 2 [get_ports  s_axis_tvalid]


set_input_delay -clock clk 1 [get_ports m_axis_tready]


set_output_delay -clock clk 1 [get_ports {m_axis_tdata[*] m_axis_tvalid}]

set_output_delay -clock clk 1 [get_ports {s_axis_tready}]

#set_property MAX_FANOUT 64 [get_nets pe_engine/crossbar_inst/SR[0]]

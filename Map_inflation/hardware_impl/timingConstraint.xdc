

create_clock -name clk -period 3.45 [get_ports clk]
set_property HD.CLK_SRC BUFGCTRL_X0Y31 [get_ports clk]

set_property HD.PARTPIN_LOCS INT_L_X28Y7 [get_ports rstn]
# Input ports - left edge of pblock SLICE_X0Y1:SLICE_X65Y38 SLICE_X26Y5:SLICE_X29Y13
#set_property HD.PARTPIN_RANGE SLICE_X32Y4:SLICE_X33Y11  [get_ports {s_axis_tdata[*]}]
# Output ports - right edge of pblock SLICE_X0Y3:SLICE_X20Y46 


# Input ports - left edge of pblock SLICE_X0Y1:SLICE_X65Y38 SLICE_X26Y5:SLICE_X29Y13
#set_property HD.PARTPIN_RANGE SLICE_X0Y1:SLICE_X65Y38   [get_ports rstn]
set_property HD.PARTPIN_RANGE SLICE_X0Y1:SLICE_X65Y38   [get_ports {s_axis_tdata[*]}]
set_property HD.PARTPIN_RANGE SLICE_X0Y1:SLICE_X65Y38   [get_ports s_axis_tvalid]
set_property HD.PARTPIN_RANGE SLICE_X0Y1:SLICE_X65Y38   [get_ports m_axis_tready]


# Output ports - right edge of pblock SLICE_X0Y3:SLICE_X20Y46 
set_property HD.PARTPIN_RANGE SLICE_X0Y1:SLICE_X65Y38 [get_ports {m_axis_tdata[*]}]
set_property HD.PARTPIN_RANGE SLICE_X0Y1:SLICE_X65Y38 [get_ports m_axis_tvalid]
set_property HD.PARTPIN_RANGE SLICE_X0Y1:SLICE_X65Y38 [get_ports s_axis_tready]

set_property DONT_TOUCH TRUE [get_ports s_axis_tdata[0]]
set_property DONT_TOUCH TRUE [get_ports s_axis_tdata[1]]
set_property DONT_TOUCH TRUE [get_ports s_axis_tdata[2]]
set_property DONT_TOUCH TRUE [get_ports s_axis_tdata[3]]
set_property DONT_TOUCH TRUE [get_ports s_axis_tdata[4]]
set_property DONT_TOUCH TRUE [get_ports s_axis_tdata[5]]
set_property DONT_TOUCH TRUE [get_ports s_axis_tdata[6]]
set_property DONT_TOUCH TRUE [get_ports s_axis_tdata[7]]
set_property DONT_TOUCH TRUE [get_ports s_axis_tdata[8]]
set_property DONT_TOUCH TRUE [get_ports s_axis_tdata[9]]
set_property DONT_TOUCH TRUE [get_ports s_axis_tdata[10]]
set_property DONT_TOUCH TRUE [get_ports s_axis_tdata[11]]
set_property DONT_TOUCH TRUE [get_ports s_axis_tdata[12]]
set_property DONT_TOUCH TRUE [get_ports s_axis_tdata[13]]
set_property DONT_TOUCH TRUE [get_ports s_axis_tdata[14]]
set_property DONT_TOUCH TRUE [get_ports s_axis_tdata[15]]
set_property DONT_TOUCH TRUE [get_ports s_axis_tdata[16]]
set_property DONT_TOUCH TRUE [get_ports s_axis_tdata[17]]
set_property DONT_TOUCH TRUE [get_ports s_axis_tdata[18]]
set_property DONT_TOUCH TRUE [get_ports s_axis_tdata[19]]
set_property DONT_TOUCH TRUE [get_ports s_axis_tdata[20]]
set_property DONT_TOUCH TRUE [get_ports s_axis_tdata[21]]
set_property DONT_TOUCH TRUE [get_ports s_axis_tdata[22]]
set_property DONT_TOUCH TRUE [get_ports s_axis_tdata[23]]
set_property DONT_TOUCH TRUE [get_ports s_axis_tdata[24]]
set_property DONT_TOUCH TRUE [get_ports s_axis_tdata[25]]
set_property DONT_TOUCH TRUE [get_ports s_axis_tdata[26]]
set_property DONT_TOUCH TRUE [get_ports s_axis_tdata[27]]
set_property DONT_TOUCH TRUE [get_ports s_axis_tdata[28]]
set_property DONT_TOUCH TRUE [get_ports s_axis_tdata[29]]
set_property DONT_TOUCH TRUE [get_ports s_axis_tdata[30]]
set_property DONT_TOUCH TRUE [get_ports s_axis_tdata[31]]




set_property DONT_TOUCH TRUE [get_nets s_axis_tdata[0]]
set_property DONT_TOUCH TRUE [get_nets s_axis_tdata[1]]
set_property DONT_TOUCH TRUE [get_nets s_axis_tdata[2]]
set_property DONT_TOUCH TRUE [get_nets s_axis_tdata[3]]
set_property DONT_TOUCH TRUE [get_nets s_axis_tdata[4]]
set_property DONT_TOUCH TRUE [get_nets s_axis_tdata[5]]
set_property DONT_TOUCH TRUE [get_nets s_axis_tdata[6]]
set_property DONT_TOUCH TRUE [get_nets s_axis_tdata[7]]
set_property DONT_TOUCH TRUE [get_nets s_axis_tdata[8]]
set_property DONT_TOUCH TRUE [get_nets s_axis_tdata[9]]
set_property DONT_TOUCH TRUE [get_nets s_axis_tdata[10]]
set_property DONT_TOUCH TRUE [get_nets s_axis_tdata[11]]
set_property DONT_TOUCH TRUE [get_nets s_axis_tdata[12]]
set_property DONT_TOUCH TRUE [get_nets s_axis_tdata[13]]
set_property DONT_TOUCH TRUE [get_nets s_axis_tdata[14]]
set_property DONT_TOUCH TRUE [get_nets s_axis_tdata[15]]
set_property DONT_TOUCH TRUE [get_nets s_axis_tdata[16]]
set_property DONT_TOUCH TRUE [get_nets s_axis_tdata[17]]
set_property DONT_TOUCH TRUE [get_nets s_axis_tdata[18]]
set_property DONT_TOUCH TRUE [get_nets s_axis_tdata[19]]
set_property DONT_TOUCH TRUE [get_nets s_axis_tdata[20]]
set_property DONT_TOUCH TRUE [get_nets s_axis_tdata[21]]
set_property DONT_TOUCH TRUE [get_nets s_axis_tdata[22]]
set_property DONT_TOUCH TRUE [get_nets s_axis_tdata[23]]
set_property DONT_TOUCH TRUE [get_nets s_axis_tdata[24]]
set_property DONT_TOUCH TRUE [get_nets s_axis_tdata[25]]
set_property DONT_TOUCH TRUE [get_nets s_axis_tdata[26]]
set_property DONT_TOUCH TRUE [get_nets s_axis_tdata[27]]
set_property DONT_TOUCH TRUE [get_nets s_axis_tdata[28]]
set_property DONT_TOUCH TRUE [get_nets s_axis_tdata[29]]
set_property DONT_TOUCH TRUE [get_nets s_axis_tdata[30]]
set_property DONT_TOUCH TRUE [get_nets s_axis_tdata[31]]





set_property DONT_TOUCH TRUE [get_ports rstn]
set_property DONT_TOUCH TRUE [get_nets -hier -filter {NAME =~ "*rstn*"}]


set_input_delay -clock clk 2 [get_ports rstn]

set_input_delay -clock clk 2 [get_ports {s_axis_tdata[*]}]

set_input_delay -clock clk 2 [get_ports  s_axis_tvalid]


set_input_delay -clock clk 1 [get_ports m_axis_tready]


set_output_delay -clock clk 1 [get_ports {m_axis_tdata[*] m_axis_tvalid}]

set_output_delay -clock clk 1 [get_ports {s_axis_tready}]

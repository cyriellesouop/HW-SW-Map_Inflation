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


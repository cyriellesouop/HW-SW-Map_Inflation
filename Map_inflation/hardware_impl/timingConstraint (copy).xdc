


create_clock -name clk_100 -period 10 [get_ports clk]

create_generated_clock -name clk \
    -source [get_ports clk] \
    -multiply_by 5 \
    -divide_by 2 \
    [get_pins mmcm_inst/CLKOUT0]


set_false_path -from [get_ports rstn]



set_input_delay -clock clk -max 1 [get_ports {s_axis_tdata[*] s_axis_tvalid}]

set_input_delay -clock clk -min 0.2 [get_ports {s_axis_tdata[*] s_axis_tvalid}]


set_input_delay -clock clk -max 1 [get_ports m_axis_tready]

set_input_delay -clock clk -min 0.2 [get_ports m_axis_tready]



set_output_delay -clock clk -max 1 [get_ports {m_axis_tdata[*] m_axis_tvalid}]

set_output_delay -clock clk -min 0.2 [get_ports {m_axis_tdata[*] m_axis_tvalid}]


set_output_delay -clock clk -max 1 [get_ports {s_axis_tready}]

set_output_delay -clock clk -min 0.2 [get_ports {s_axis_tready}]



# Global variable
set proj_name "project1"
set proj_dir "./project1"
set part_name "xc7s50csga324-2"
set top_module "top"

set sim_top_module "top_tb.v"
set sim_fifo "fifo_tb"
set sim_fifo_axis "fifo_axis_tb"
set sim_grayscale "grayscale_tb.v"
#set sim_writer "tb_writer"
#set sim_fifo "fifo_tb"
#set sim_multiplier "tb_multiplier"


set bitfile "grayscale.bit"

#////////////////////////
# 1- simulation
#////////////////////////


file mkdir sim
cd sim
file mkdir work
cd work

# compile design and testbench
exec xvlog ./../../fifo_axis.v
exec xvlog ./../../fifo.v
exec xvlog ./../../grayscale.v
exec xvlog ./../../top.v

#testbenches
exec xvlog ./../../fifo_tb.v
exec xvlog ./../../fifo_axis_tb.v
exec xvlog ./../../grayscale_tb.v
exec xvlog ./../../top_tb.v

 
#elaborate
exec xelab $sim_top_module -debug all
exec xelab $sim_fifo -debug all
exec xelab $sim_fifo_axis -debug all
exec xelab $sim_grayscale -debug all


#simulation
exec xsim $sim_grayscale - R
exec xsim $sim_fifo -R
exec xsim $sim_fifo_axis -R
exec  xsim $sim_top_module --tclbatch ./../../sim.tcl
cd ../..

#////////////////////////
# 2- synthesis , place and route
#////////////////////////
catch {close_design}

file mkdir synth_place_route
cd  synth_place_route

#load design sources
read_verilog ./../fifo_axis.v
read_verilog ./../fifo.v
read_verilog ./../grayscale.v


#load constraints files
read_xdc ./../timingConstraint.xdc

# synthesis
synth_design -top $top_module -part $part_name
write_checkpoint -force  synth_checkpoint.dcp
# optimization
opt_design

#placement
place_design

# post-placement optimization
phys_opt_design

#routing
route_design

#post routing optimization
phys_opt_design
write_checkpoint -force final_checkpoint.dcp
#reports
report_utilization -file  utilization.rpt
report_timing_summary -file timing_summary.rpt

read_saif -strip_path fifo_axis_tb/DUT ./../sim/work/myTop.saif

report_power -file power_utilization.rpt
report_power_opt -file power_opt.rpt
report_route_status -file route_status.rpt
report_place_status -file place_status.rpt

#set_property SEVERITY {warning} [get_drc_checks NSTD-1]
#set_property SEVERITY {warning} [get_drc_checks UCIO-1]

# Bistream generation
#write_bitstream -force $bitfile

#////////////////////////
# 3- programming the hw
#////////////////////////

#program device
#open_hw_manager
#connect_hw_server -allow_non_jtag
#open_hw_target
#set_property PROGRAM.FILE {/home/audrey/Documents/Verilog_course/dotProduct2/synth_place_route/reader.bit} [get_hw_devices xc7s50_0]
#current_hw_device [get_hw_devices xc7s50_0]
#refresh_hw_device -update_hw_probes false [lindex [get_hw_devices xc7s50_0] 0]
#set_property PROBES.FILE {} [get_hw_devices xc7s50_0]
#set_property FULL_PROBES.FILE {} [get_hw_devices xc7s50_0]
#set_property PROGRAM.FILE {/home/audrey/Documents/Verilog_course/dotProduct2/synth_place_route/reader.bit} [get_hw_devices xc7s50_0]
#program_hw_devices [get_hw_devices xc7s50_0]
#refresh_hw_device [lindex [get_hw_devices xc7s50_0] 0]

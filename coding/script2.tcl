
# Global variable
set proj_name "project1"
set proj_dir "./project1"
set part_name "xc7s50csga324-2"
set top_module "pe_array"

set sim_top_module "tb_pe_array"
set sim_adder "tb_adder"
set sim_pe "tb_pe"

set bitfile "convolution.bit"

#////////////////////////
# 1- simulation
#////////////////////////


file mkdir sim
cd sim
file mkdir work
cd work

# compile design and testbench
exec xvlog ./../../pe.v
exec xvlog ./../../half_adder.v
exec xvlog ./../../full_adder.v
exec xvlog ./../../adder.v
exec xvlog ./../../pe_array.v
exec xvlog ./../../fifo.v
exec xvlog ./../../fifo_axis.v

#exec xvlog ./../../tb_fifo.v
#testbenches
exec xvlog ./../../tb_fifo.v
exec xvlog ./../../tb_fifo_axis.v
exec xvlog ./../../tb_adder.v
exec xvlog ./../../tb_pe.v
exec xvlog ./../../tb_pe_array.v
 
#elaborate
exec xelab $sim_adder -debug all 
exec xelab $sim_pe -debug all
exec xelab $sim_top_module -debug all

#simulation

exec  xsim $sim_pe -R
exec  xsim $sim_adder -R
exec  xsim $sim_top_module --tclbatch ./../../sim.tcl
cd ../..

#////////////////////////
# 2- synthesis , place and route
#////////////////////////
catch {close_design}

file mkdir synth_place_route
cd  synth_place_route

#load design sources
read_verilog ./../half_adder.v
read_verilog ./../full_adder.v
read_verilog ./../adder.v
read_verilog ./../pe.v
read_verilog ./../pe_array.v

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

read_saif -strip_path tb_pe_array/DUT ./../sim/work/myTop.saif

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

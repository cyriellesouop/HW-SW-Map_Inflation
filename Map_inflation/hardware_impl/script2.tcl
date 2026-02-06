
# Global variable
set proj_name "project1"
set proj_dir "./project1"
set part_name "xc7s50csga324-2"
set top_module "top"

set sim_top_module "tb_top2"
set sim_pe "tb_pe"
#set sim_adder "tb_adder"
set sim_axim_reg "tb_axim_reg"
set sim_top_fifo "tb_top_fifo"
set sim_fifo "tb_fifo"
set sim_weight_loader "tb_weight_loader"
#set sim_pe_wrapper "tb_pe_wrapper"


set bitfile "mapinflation.bit"

#////////////////////////
# 1- simulation
#////////////////////////


file mkdir sim
cd sim
file mkdir work
cd work

# compile design and testbench
exec xvlog ./../../pe.v
exec xvlog ./../../adder_tree.v
exec xvlog -sv ./../../data_accumulator.sv
exec xvlog -sv ./../../weight_loader.sv
exec xvlog -sv ./../../axim_reg.sv
exec xvlog ./../../fifo.v
exec xvlog ./../../fifo_axis.v
exec xvlog ./../../top_fifo.v
exec xvlog ./../../axis_unpack_data.v
exec xvlog ./../../delay.v
exec xvlog ./../../crossbar.v
exec xvlog ./../../pe_wrapper.v
exec xvlog ./../../top.v
#exec xvlog ./../../fsm.v

#testbenches
#exec xvlog ./../../testbench.v
exec xvlog ./../../tb_pe.v
#exec xvlog ./../../tb_adder.v
exec xvlog ./../../tb_weight_loader.v
exec xvlog ./../../tb_axim_reg.v
exec xvlog ./../../tb_top_fifo.v
exec xvlog ./../../tb_fifo.v
#exec xvlog ./../../tb_pe_wrapper.v
exec xvlog ./../../tb_top2.v
 
#elaborate
#exec xelab $sim_top_module -debug all
exec xelab $sim_pe -debug all
#exec xelab $sim_adder -debug all
exec xelab  $sim_weight_loader -debug all
exec xelab $sim_axim_reg -debug all
exec xelab $sim_fifo -debug all
exec xelab  $sim_top_fifo -debug all
#exec xelab  $sim_pe_wrapper -debug all
exec xelab $sim_top_module -debug all

#simulation

#exec xsim $sim_pe -R
#exec xsim $sim_adder -R
#exec xsim  $sim_weight_loader -R
#exec xsim $sim_axim_reg -R
#exec xsim $sim_fifo -R
#exec xsim $sim_top_fifo -R
#exec xsim  $sim_pe_wrapper -R
#exec  xsim $sim_top_module -R
exec  xsim $sim_top_module --tclbatch ./../../sim.tcl
cd ../..

#////////////////////////
# 2- synthesis , place and route
#////////////////////////
catch {close_design}

file mkdir synth_place_route
cd  synth_place_route

#load design sources
read_verilog ./../pe.v
read_verilog ./../adder_tree.v
read_verilog  -sv ./../data_accumulator.sv
read_verilog -sv ./../weight_loader.sv
read_verilog -sv ./../axim_reg.sv
read_verilog ./../fifo.v
read_verilog ./../fifo_axis.v
read_verilog ./../top_fifo.v
read_verilog ./../axis_unpack_data.v
read_verilog ./../delay.v
read_verilog ./../pe_wrapper.v
read_verilog ./../crossbar.v
read_verilog ./../top.v


#load constraints files
read_xdc ./../timingConstraint.xdc
#read_xdc ./../floorPlan.xdc
#Vivado% set_property CARRY_REMAP 1 [get_cells -hier -filter {ref_name == CARRY8}]
# synthesis
synth_design -top $top_module -part $part_name -directive LogicCompaction 
#-mode out_of_context -directive LogicCompaction 
write_checkpoint -force  synth_checkpoint.dcp
# optimization
opt_design  -remap -resynth_remap 

#placement
place_design 

# post-placement optimization
phys_opt_design  -placement_opt -dsp_register_opt

#routing
route_design -directive AggressiveExplore


#post routing optimization
phys_opt_design -routing_opt 
write_checkpoint -force final_checkpoint.dcp
#reports
report_utilization -file  utilization.rpt
report_timing_summary -file timing_summary.rpt

read_saif -strip_path tb_top2/DUT ./../sim/work/myTop.saif

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

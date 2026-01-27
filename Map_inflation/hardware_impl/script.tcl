
# Global variable
set proj_name "project1"
set proj_dir "./project1"
set part_name "xc7s50csga324-2"
set top_module "top"
set sim_top_module "testbench"

#create project
create_project  $proj_name $proj_dir -part $part_name -force

#add design sources
add_files -fileset sources_1 ./fifo.v
add_files -fileset sources_1 ./memory.v
add_files -fileset sources_1 ./fsm.v
add_files -fileset sources_1 ./memory_reader.v
add_files -fileset sources_1 ./memory_writer.v
add_files -fileset sources_1 ./multiplier.v
add_files -fileset sources_1 ./top.v

#set top-level file
set_property top $top_module [get_filesets sources_1]

#add simulation files
add_files -fileset sim_1 ./testbench.v

#set testbench top-level
set_property top $sim_top_module [get_filesets sim_1]

#add constraint files
add_files -fileset constrs_1 ./timingConstraint.xdc

# run simulation
launch_simulation -simset sim_1 -mode behavioral 

#run synthesis
launch_runs synth_1 -jobs 2
wait_on_run synth_1


# run implementation
launch_runs impl_1 -to_step route_design
wait_on_run impl_1

#program device
#open_hw_manager
#connect_hw_server -allow_non_jtag
#open_hw_target
#set_property PROGRAM.FILE {/home/audrey/Documents/Verilog_course/counter/tcl_script/project1/project1.runs/impl_1/counter.bit} [get_hw_devices xc7s50_0]
#current_hw_device [get_hw_devices xc7s50_0]
#refresh_hw_device -update_hw_probes false [lindex [get_hw_devices xc7s50_0] 0]
#set_property PROBES.FILE {} [get_hw_devices xc7s50_0]
#set_property FULL_PROBES.FILE {} [get_hw_devices xc7s50_0]
#set_property PROGRAM.FILE {/home/audrey/Documents/Verilog_course/counter/tcl_script/project1/project1.runs/impl_1/counter.bit} [get_hw_devices xc7s50_0]
#program_hw_devices [get_hw_devices xc7s50_0]
#refresh_hw_device [lindex [get_hw_devices xc7s50_0] 0]

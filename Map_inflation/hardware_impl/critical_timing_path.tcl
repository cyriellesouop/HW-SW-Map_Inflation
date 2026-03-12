# 1. Get the critical timing path and assign it to a variable
set my_path [get_timing_paths -max_paths 1 -nworst 1 -setup]

# 2. Open the Schematic tool using the timing path object directly
# The -objects flag works here for a timing path
show_schematic -objects $my_path

set my_path [get_timing_paths -max_paths 1 -nworst 1 -setup]
#{unpacker/genblk1[2].fifo_inst/fifo_inst/wr_addr_reg[1]/C --> unpacker/genblk1[0].fifo_inst/fifo_inst/MEM_reg_0_3_6_7/DP/WE}
show_schematic -objects $my_path
write_schematic -format pdf -orientation portrait -scope visible /home/audrey/Documents/convolution/Map_inflation/hardware_impl/FPL_result/3X3/schematic.pdf
/#home/audrey/Documents/convolution/Map_inflation/hardware_impl/FPL_result/3X3/schematic.pdf
write_schematic /home/audrey/Documents/convolution/Map_inflation/hardware_impl/FPL_result/3X3/schematic.sch
#/home/audrey/Documents/convolution/Map_inflation/hardware_impl/FPL_result/3X3/schematic.sch
write_schematic -format pdf -orientation portrait -scope visible -force /home/audrey/Documents/convolution/Map_inflation/hardware_impl/FPL_result/3X3/schematic.pdf
#/home/audrey/Documents/convolution/Map_inflation/hardware_impl/FPL_result/3X3/schematic.pdf

#Would you like me to generate a Tcl command to create a "Routing Map" image showing your 32 bits perfectly spread across the X21 column for your paper's figures?





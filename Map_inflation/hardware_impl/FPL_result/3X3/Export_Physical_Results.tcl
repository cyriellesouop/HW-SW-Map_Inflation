# 1. Open the results file for your conference paper
set fp [open "physical_integrity_export.txt" w]
puts $fp "Physical Metric | Value"
puts $fp "-------------------------------|-----------------------"

# 2. Routing Health Metrics (Proof of Rountability)
# These verify you have solved the "Islands" and "Antennas" issues
set antenna_nets [get_nets -filter {ROUTE_STATUS == "ANTENNAS"}]
set island_nets [get_nets -filter {ROUTE_STATUS == "ISLANDS"}]
puts $fp "Total Routing Antennas         | [llength $antenna_nets]"
puts $fp "Total Routing Islands          | [llength $island_nets]"

# 3. Manual Logic Placement Verification (Inter-Slice Isolation)
# This validates your "Silicon-Aware" register placement
set cells_34_7  [get_cells -of_objects [get_sites SLICE_X34Y7]]
set cells_34_8  [get_cells -of_objects [get_sites SLICE_X34Y8]]
set cells_30_11 [get_cells -of_objects [get_sites SLICE_X30Y11]]

puts $fp "Cells at SLICE_X34Y7 (Accum)   | [llength $cells_34_7]"
puts $fp "Cells at SLICE_X34Y8 (Weight)  | [llength $cells_34_8]"
puts $fp "Cells at SLICE_X30Y11 (Weight) | [llength $cells_30_11]"

# 4. Partition Pin Distribution (I/O Congestion Management)
# This counts your manually placed AXI-Stream pins
set managed_ports [get_ports -filter {HD.PARTPIN_LOCS != ""}]
puts $fp "Managed AXI-Stream Pins        | [llength $managed_ports]"

# Close the file and provide feedback
close $fp
puts "Export Complete: 'physical_integrity_export.txt' has been generated."

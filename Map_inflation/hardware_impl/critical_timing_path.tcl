# 1. Get the critical timing path and assign it to a variable
set my_path [get_timing_paths -max_paths 1 -nworst 1 -setup]

# 2. Open the Schematic tool using the timing path object directly
# The -objects flag works here for a timing path
show_schematic -objects $my_path

# Open the resource file
set fp [open "resource_utilization.txt" w]
puts $fp "Resource | Used | Available | Utilization %"
puts $fp "---------------------------------------------"

# Get report_utilization and format it
set util [report_utilization -return_string]
# This captures the table; you can also use specific 'get_utilization' commands 
# if you want to parse the numbers into the file directly:
puts $fp $util
close $fp

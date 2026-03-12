# ============================================================
# Global variables
# ============================================================
set proj_name  "project1"
set proj_dir   "./project1"
set part_name  "xc7s50csga324-2"
set top_module "top"

set sim_pe            "tb_pe"
set sim_axim_reg      "tb_axim_reg"
set sim_top_fifo      "tb_top_fifo"
set sim_fifo          "tb_fifo"
set sim_weight_loader "tb_weight_loader"

# One dedicated testbench per kernel size
array set sim_top_per_k {
    3 "tb_top3"
    5 "tb_top5"
    7 "tb_top7"
}

# One dedicated SAIF per kernel size
array set saif_per_k {
    3 "./../sim/work/myTop_K3.saif"
    5 "./../sim/work/myTop_K5.saif"
    7 "./../sim/work/myTop_K7.saif"
}

set bitfile "mapinflation.bit"

# CSV results file — appended for each kernel size run
set results_csv "./results/metrics.csv"

# ============================================================
# Helper: extract metrics and append one row to CSV
# ============================================================
proc extract_and_log {kernel_size csv_file} {

    # --- Timing: Fmax from worst negative slack ---
    set wns 0.0
    set period 3.333
    catch {
        set timing [report_timing_summary -return_string -no_header]
        regexp {WNS\(ns\)\s+([-0-9.]+)} $timing -> wns
        # Fmax = 1 / (period - WNS) in MHz
    }
    set fmax [expr {1000.0 / ($period - $wns)}]

    # --- Resource utilization ---
    set lut    0
    set ff     0
    set dsp    0
    set bram   0
    set lut_pct  0.0
    set ff_pct   0.0
    set dsp_pct  0.0
    set bram_pct 0.0

    catch {
        set util [report_utilization -return_string]

        regexp {Slice LUTs\s*\|\s*(\d+)\s*\|\s*\d+\s*\|\s*\d+\s*\|\s*([\d.]+)} \
            $util -> lut lut_pct
        regexp {Slice Registers\s*\|\s*(\d+)\s*\|\s*\d+\s*\|\s*\d+\s*\|\s*([\d.]+)} \
            $util -> ff ff_pct
        regexp {DSPs\s*\|\s*(\d+)\s*\|\s*\d+\s*\|\s*\d+\s*\|\s*([\d.]+)} \
            $util -> dsp dsp_pct
        regexp {Block RAM Tile\s*\|\s*([\d.]+)\s*\|\s*\d+\s*\|\s*\d+\s*\|\s*([\d.]+)} \
            $util -> bram bram_pct
    }

    # --- Power: dynamic power from report_power ---
    set dyn_power 0.0
    catch {
        set pwr [report_power -return_string]
        regexp {Dynamic \(W\)\s*\|\s*([\d.]+)} $pwr -> dyn_power
    }

    # --- Write CSV row ---
    set fd [open $csv_file a]
    puts $fd "$kernel_size,[format %.1f $fmax],$lut,[format %.1f $lut_pct],$ff,[format %.1f $ff_pct],$dsp,[format %.1f $dsp_pct],$bram,[format %.1f $bram_pct],[format %.4f $dyn_power]"
    close $fd

    puts "K=$kernel_size | Fmax=[format %.1f $fmax] MHz | LUT=$lut ($lut_pct%) | FF=$ff ($ff_pct%) | DSP=$dsp ($dsp_pct%) | BRAM=$bram | Power=[format %.4f $dyn_power] W"
}

# ============================================================
# 1 — Simulation: compile once, elaborate and run per kernel
# ============================================================
file mkdir sim
cd sim
file mkdir work
cd work

exec xvlog /home/audrey/Xilinx/Vivado/2024.2/data/verilog/src/glbl.v

# Compile shared RTL sources
foreach src {pe.v adder_tree.v data_accumulator.v fifo.v fifo_axis.v
             top_fifo.v axis_unpack_data.v delay.v crossbar.v
             pe_wrapper.v top.v} {
    exec xvlog ./../../$src
}
exec xvlog -sv ./../../weight_loader.sv
exec xvlog -sv ./../../axim_reg.sv

# Compile shared unit testbenches
foreach tb {tb_pe.v tb_weight_loader.v tb_axim_reg.v
            tb_top_fifo.v tb_fifo.v} {
    exec xvlog ./../../$tb
}

# Compile per-kernel top-level testbenches
exec xvlog ./../../tb_top3.v
exec xvlog ./../../tb_top5.v
exec xvlog ./../../tb_top7.v

# Elaborate and simulate shared unit testbenches
exec xelab $sim_pe            -debug all
exec xelab $sim_weight_loader -debug all
exec xelab $sim_axim_reg      -debug all
exec xelab $sim_fifo          -debug all
exec xelab $sim_top_fifo      -debug all

# Elaborate and simulate each kernel-specific top-level testbench
# Each generates its own SAIF for accurate power estimation
foreach kernel_size {3 5 7} {
    set tb_name $sim_top_per_k($kernel_size)
    set saif    $saif_per_k($kernel_size)
    set snap    "sim_snapshot_K${kernel_size}"

    puts "\n--- Simulating $tb_name (K=$kernel_size) ---"

    exec xelab $tb_name glbl \
        -L unisim_ver -L unisims_ver \
        -debug all -snapshot $snap

    # Pass SAIF output path via TCL variable so sim.tcl can pick it up
    exec xsim $snap --tclbatch ./../../sim.tcl \
        --sv_seed 1 \
        --testplusarg "SAIF_FILE=$saif"
}

cd ../..

# ============================================================
# 2 — Synthesis, P&R and metrics sweep over K in {3, 5, 7}
# ============================================================

# Initialise CSV with header
file mkdir results
set fd [open $results_csv w]
puts $fd "Kernel_Size,Fmax_MHz,LUT,LUT_pct,FF,FF_pct,DSP,DSP_pct,BRAM,BRAM_pct,Dynamic_Power_W"
close $fd

foreach kernel_size {3 5 7} {

    puts "\n================================================"
    puts " Running implementation for K = $kernel_size"
    puts "================================================"

    set run_dir "./synth_place_route_K${kernel_size}"
    file mkdir $run_dir
    cd $run_dir

    catch {close_design}

    # Load sources
    read_verilog ./../pe.v
    read_verilog ./../adder_tree.v
    read_verilog ./../data_accumulator.v
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

    read_xdc ./../timingConstraint.xdc

    # Override KERNEL_SIZE parameter for this run
    synth_design \
        -mode out_of_context \
        -top $top_module \
        -part $part_name \
        -directive LogicCompaction \
        -generic "KERNEL_SIZE=$kernel_size"

    write_checkpoint -force synth_checkpoint_K${kernel_size}.dcp

    opt_design -remap -resynth_remap
    place_design
    phys_opt_design \
        -insert_negative_edge_ffs \
        -placement_opt \
        -dsp_register_opt \
        -hold_fix

    route_design -tns_cleanup -directive AggressiveExplore
    route_design -unroute
    place_design -post_place_opt
    route_design -directive AggressiveExplore
    phys_opt_design -routing_opt -hold_fix

    write_checkpoint -force final_checkpoint_K${kernel_size}.dcp

    # Save individual reports
    report_utilization   -file utilization_K${kernel_size}.rpt
    report_timing_summary -file timing_summary_K${kernel_size}.rpt

    # Load kernel-specific SAIF for accurate power estimation
    set saif_file $saif_per_k($kernel_size)
    set tb_name   $sim_top_per_k($kernel_size)
    catch {
        read_saif -strip_path ${tb_name}/DUT $saif_file
    }
    report_power         -file power_K${kernel_size}.rpt
    report_route_status  -file route_status_K${kernel_size}.rpt
    report_place_status  -file place_status_K${kernel_size}.rpt

    # Extract and log metrics to CSV
    extract_and_log $kernel_size ./../$results_csv

    cd ..
}

puts "\n✓ All runs complete. Results saved to: $results_csv"

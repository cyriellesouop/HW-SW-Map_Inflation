#!/bin/sh
#source /home/cyrielle/tools_2022_1/Xilinx2022_1/Vivado/2022.1/settings64.sh || exit 1
source /home/cyrielle/tools/Xilinx/Vivado/2024.2/settings64.sh || exit 1

rm -rf sim synth_place_route  *.log *.jou
vivado -mode batch -source script2.tcl

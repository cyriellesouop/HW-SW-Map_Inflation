#!/bin/sh
rm -rf sim synth_place_route  *.log *.jou
vivado -mode batch -source script2.tcl

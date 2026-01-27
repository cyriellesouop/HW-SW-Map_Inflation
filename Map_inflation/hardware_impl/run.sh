#!/bin/sh

rm -f *.log *.jou *.wdb
vivado -mode batch -source script.tcl

#!/bin/sh

rm -f *.log *.jou *.wdb
vivado2022 -mode batch -source script.tcl

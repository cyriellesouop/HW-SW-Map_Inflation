#! /bin/sh

rm -rf xsim.dir
rm -f *.log *.jou *.wdb



xvlog fifo_axis.v
xvlog fifo.v

xvlog fifo_axis_tb.v
xelab fifo_axis_tb -debug all
xsim fifo_axis_tb -R







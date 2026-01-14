#! /bin/sh

rm -rf xsim.dir
rm -f *.log *.jou *.wdb


xvlog fifo.v

xvlog fifo_axis.v

xvlog adder_tree.v

#xvlog tb_adder_tree.v

xvlog pe.v

xvlog pe_array.v

xvlog -sv fsm.sv

xvlog top.v

xvlog tb_top.v

#xvlog tb_fsm.v

xvlog tb_pe_array.v

xelab tb_pe_array -debug all

xsim tb_pe_array -R

#xelab  tb_top -debug all
 
#xsim  tb_top  -R



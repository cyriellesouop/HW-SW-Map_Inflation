#! /bin/sh

rm -rf xsim.dir
rm -f *.log *.jou *.wdb *.str *.pb


#xvlog fifo.v

#xvlog fifo_axis.v

#xvlog axis_unpack_data.v

#xvlog top_fifo.v

#xvlog tb_top_fifo.v

#xelab tb_top_fifo -debug all

#xsim tb_top_fifo -R


#xvlog -sv axim_reg.sv

#xvlog -sv tb_axim_reg.v

#xelab tb_axim_reg --debug all

#xsim tb_axim_reg -R


xvlog pe.v

xvlog adder_tree.v

xvlog delay.v

xvlog pe_wrapper.v

xvlog tb_pe.v

xvlog tb_pe_wrapper.v

xelab tb_pe_wrapper -debug all

xsim tb_pe_wrapper -R

#xvlog adder_tree.v

#xvlog tb_adder.v

#xelab tb_adder -debug all

#xsim tb_adder -R


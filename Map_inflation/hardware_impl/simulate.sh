#! /bin/sh

rm -rf xsim.dir
rm -f *.log *.jou *.wdb *.str *.pb


xvlog fifo.v

xvlog fifo_axis.v

xvlog axis_unpack_data.v

xvlog top_fifo.v

xvlog -sv axim_reg.sv

#xvlog -sv tb_axim_reg.v

#xelab tb_axim_reg --debug all

#xsim tb_axim_reg -R

xvlog  -sv weight_loader.sv

xvlog  -sv data_accumulator.sv

#xvlog  tb_weight_loader.v

#xelab tb_weight_loader -debug all

#xsim tb_weight_loader -R

xvlog pe.v

xvlog adder_tree.v

xvlog delay.v

xvlog pe_wrapper.v

#xvlog tb_pe.v

#xvlog tb_pe_wrapper.v

#xelab tb_pe_wrapper -debug all

#xsim tb_pe_wrapper -R

#xvlog adder_tree.v

#xvlog tb_adder.v

#xelab tb_adder -debug all

#xsim tb_adder -R

xvlog top.v

xvlog tb_top2.v

xelab tb_top2 -debug all

xsim tb_top2 -R


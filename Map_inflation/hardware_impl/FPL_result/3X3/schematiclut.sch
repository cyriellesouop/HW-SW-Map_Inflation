# File saved with Nlview 7.8.0 2024-04-26 e1825d835c VDI=44 GEI=38 GUI=JA:21.0 TLS
# 
# non-default properties - (restore without -noprops)
property -colorscheme classic
property attrcolor #000000
property attrfontsize 8
property autobundle 1
property backgroundcolor #ffffff
property boxcolor0 #000000
property boxcolor1 #000000
property boxcolor2 #000000
property boxinstcolor #000000
property boxpincolor #000000
property buscolor #008000
property closeenough 5
property createnetattrdsp 2048
property decorate 1
property elidetext 40
property fillcolor1 #ffffcc
property fillcolor2 #dfebf8
property fillcolor3 #f0f0f0
property gatecellname 2
property instattrmax 30
property instdrag 15
property instorder 1
property marksize 12
property maxfontsize 12
property maxzoom 5
property netcolor #19b400
property objecthighlight0 #ff00ff
property objecthighlight1 #ffff00
property objecthighlight2 #00ff00
property objecthighlight3 #0095ff
property objecthighlight4 #8000ff
property objecthighlight5 #ffc800
property objecthighlight7 #00ffff
property objecthighlight8 #ff00ff
property objecthighlight9 #ccccff
property objecthighlight10 #0ead00
property objecthighlight11 #cefc00
property objecthighlight12 #9e2dbe
property objecthighlight13 #ba6a29
property objecthighlight14 #fc0188
property objecthighlight15 #02f990
property objecthighlight16 #f1b0fb
property objecthighlight17 #fec004
property objecthighlight18 #149bff
property objecthighlight19 #eb591b
property overlaycolor #19b400
property pbuscolor #000000
property pbusnamecolor #000000
property pinattrmax 20
property pinorder 2
property pinpermute 0
property portcolor #000000
property portnamecolor #000000
property ripindexfontsize 4
property rippercolor #000000
property rubberbandcolor #000000
property rubberbandfontsize 12
property selectattr 0
property selectionappearance 2
property selectioncolor #0000ff
property sheetheight 44
property sheetwidth 68
property showmarks 1
property shownetname 0
property showpagenumbers 1
property showripindex 1
property timelimit 1
#
module new top work:top:NOFILE -nosplit
load symbol pe_wrapper work:pe_wrapper:NOFILE HIERBOX pin clk input.left pin m_axis_tready input.left pin m_axis_tvalid output.right pin out input.left pin pe_en_delayed input.left pin rd_addr_reg[0] output.right pin rd_addr_reg[0]_0 output.right pin rd_addr_reg[0]_1 output.right pin rd_addr_reg[0]_2 input.left pin rd_addr_reg[0]_3 input.left pin rd_addr_reg[0]_4 input.left pin rd_cnt1 output.right pin rd_cnt1_0 output.right pin rd_cnt1_1 output.right pin ready output.right pinBus Q input.left [71:0] pinBus dataIn input.left [23:0] pinBus m_axis_tdata output.right [17:0] pinBus rd_addr input.left [0:0] pinBus rd_addr_2 input.left [0:0] pinBus rd_addr_3 input.left [0:0] boxcolor 1 fillcolor 2 minwidth 13%
load symbol pe__xdcDup__6 work:pe__xdcDup__6:NOFILE HIERBOX pin clk input.left pin out input.left pin pe_done_reg_0 output.right pin pe_done_reg_1 output.right pin pe_done_reg_10 output.right pin pe_done_reg_11 output.right pin pe_done_reg_12 output.right pin pe_done_reg_13 output.right pin pe_done_reg_14 output.right pin pe_done_reg_15 output.right pin pe_done_reg_2 output.right pin pe_done_reg_3 output.right pin pe_done_reg_4 output.right pin pe_done_reg_5 output.right pin pe_done_reg_6 output.right pin pe_done_reg_7 output.right pin pe_done_reg_8 output.right pin pe_done_reg_9 output.right pin pe_en input.left pinBus Q input.left [7:0] pinBus dataIn input.left [7:0] pinBus genblk1[1].row_pe_dones output.right [0:0] pinBus tree_flat_reg[2][0] input.left [1:0] boxcolor 1 fillcolor 2 minwidth 13%
load symbol FDRE hdi_primitives GEN pin Q output.right pin C input.clk.left pin CE input.left pin D input.left pin R input.left fillcolor 1
load symbol LUT6 hdi_primitives BOX pin O output.right pin I0 input.left pin I1 input.left pin I2 input.left pin I3 input.left pin I4 input.left pin I5 input.left fillcolor 1
load symbol CARRY4 hdi_primitives BOX pin CI input.left pin CYINIT input.left pinBus CO output.right [3:0] pinBus O output.right [3:0] pinBus DI input.left [3:0] pinBus S input.left [3:0] fillcolor 1
load symbol LUT4 hdi_primitives BOX pin O output.right pin I0 input.left pin I1 input.left pin I2 input.left pin I3 input.left fillcolor 1
load inst pe_engine pe_wrapper work:pe_wrapper:NOFILE -autohide -attr @cell(#000000) pe_wrapper -attr @fillcolor #fafafa -pinBusAttr Q @name Q[71:0] -pinBusAttr dataIn @name dataIn[23:0] -pinBusAttr m_axis_tdata @name m_axis_tdata[17:0] -pinBusAttr rd_addr @name rd_addr -pinBusAttr rd_addr_2 @name rd_addr_2 -pinBusAttr rd_addr_3 @name rd_addr_3 -pg 1 -lvl 1 -x 10 -y 70
load inst pe_engine|genblk1[1].genblk1[2].pe_inst pe__xdcDup__6 work:pe__xdcDup__6:NOFILE -hier pe_engine -autohide -attr @name genblk1[1].genblk1[2].pe_inst -attr @cell(#000000) pe__xdcDup__6 -attr @fillcolor #fafafa -pinBusAttr Q @name Q[7:0] -pinBusAttr dataIn @name dataIn[7:0] -pinBusAttr genblk1[1].row_pe_dones @name genblk1[1].row_pe_dones -pinBusAttr tree_flat_reg[2][0] @name tree_flat_reg[2][0][1:0] -pg 1 -lvl 1 -x 20 -y 110
load inst pe_engine|genblk1[1].genblk1[2].pe_inst|pe_input_reg_reg[4] FDRE hdi_primitives -hier pe_engine|genblk1[1].genblk1[2].pe_inst -attr @name pe_input_reg_reg[4] -attr @cell(#000000) FDRE -pg 1 -lvl 1 -x 80 -y 160
load inst pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output[6]_i_8__2 LUT6 hdi_primitives -hier pe_engine|genblk1[1].genblk1[2].pe_inst -attr @name pe_output[6]_i_8__2 -attr @cell(#000000) LUT6 -pg 1 -lvl 2 -x 260 -y 130
load inst pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output[6]_i_12__2 LUT6 hdi_primitives -hier pe_engine|genblk1[1].genblk1[2].pe_inst -attr @name pe_output[6]_i_12__2 -attr @cell(#000000) LUT6 -pg 1 -lvl 3 -x 450 -y 170
load inst pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output_reg[6]_i_3 CARRY4 hdi_primitives -hier pe_engine|genblk1[1].genblk1[2].pe_inst -attr @name pe_output_reg[6]_i_3 -attr @cell(#000000) CARRY4 -pinBusAttr CO @name CO[3:0] -pinBusAttr O @name O[3:0] -pinBusAttr DI @name DI[3:0] -pinBusAttr S @name S[3:0] -pg 1 -lvl 4 -x 610 -y 150
load inst pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output_reg[14]_i_21 CARRY4 hdi_primitives -hier pe_engine|genblk1[1].genblk1[2].pe_inst -attr @name pe_output_reg[14]_i_21 -attr @cell(#000000) CARRY4 -pinBusAttr CO @name CO[3:0] -pinBusAttr O @name O[3:0] -pinBusAttr DI @name DI[3:0] -pinBusAttr S @name S[3:0] -pg 1 -lvl 5 -x 810 -y 170
load inst pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output[10]_i_10__2 LUT4 hdi_primitives -hier pe_engine|genblk1[1].genblk1[2].pe_inst -attr @name pe_output[10]_i_10__2 -attr @cell(#000000) LUT4 -pg 1 -lvl 6 -x 1050 -y 150
load inst pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output[10]_i_6__2 LUT6 hdi_primitives -hier pe_engine|genblk1[1].genblk1[2].pe_inst -attr @name pe_output[10]_i_6__2 -attr @cell(#000000) LUT6 -pg 1 -lvl 7 -x 1250 -y 150
load inst pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output_reg[10]_i_1 CARRY4 hdi_primitives -hier pe_engine|genblk1[1].genblk1[2].pe_inst -attr @name pe_output_reg[10]_i_1 -attr @cell(#000000) CARRY4 -pinBusAttr CO @name CO[3:0] -pinBusAttr O @name O[3:0] -pinBusAttr DI @name DI[3:0] -pinBusAttr S @name S[3:0] -pg 1 -lvl 8 -x 1420 -y 130
load inst pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output_reg[14]_i_1 CARRY4 hdi_primitives -hier pe_engine|genblk1[1].genblk1[2].pe_inst -attr @name pe_output_reg[14]_i_1 -attr @cell(#000000) CARRY4 -pinBusAttr CO @name CO[3:0] -pinBusAttr O @name O[3:0] -pinBusAttr DI @name DI[3:0] -pinBusAttr S @name S[3:0] -pg 1 -lvl 9 -x 1630 -y 150
load inst pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output_reg[15]_i_1 CARRY4 hdi_primitives -hier pe_engine|genblk1[1].genblk1[2].pe_inst -attr @name pe_output_reg[15]_i_1 -attr @cell(#000000) CARRY4 -pinBusAttr CO @name CO[3:0] -pinBusAttr CO @attr n/c -pinBusAttr O @name O[3:0] -pinBusAttr DI @name DI[3:0] -pinBusAttr S @name S[3:0] -pg 1 -lvl 10 -x 1840 -y 170
load inst pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output_reg[15] FDRE hdi_primitives -hier pe_engine|genblk1[1].genblk1[2].pe_inst -attr @name pe_output_reg[15] -attr @cell(#000000) FDRE -pg 1 -lvl 11 -x 2070 -y 210
load net pe_engine|genblk1[1].genblk1[2].pe_inst|pe_input_reg_reg_n_0_[4] -attr @style dashed -attr @name pe_input_reg_reg_n_0_[4] -pin pe_engine|genblk1[1].genblk1[2].pe_inst|pe_input_reg_reg[4] Q -pin pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output[6]_i_8__2 I1
netloc pe_engine|genblk1[1].genblk1[2].pe_inst|pe_input_reg_reg_n_0_[4] 1 1 1 NJ 160
load net pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output[6]_i_8__2_n_0 -attr @style dashed -attr @name pe_output[6]_i_8__2_n_0 -attr @rip(#000000) 3 -pin pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output[6]_i_12__2 I0 -pin pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output[6]_i_8__2 O
netloc pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output[6]_i_8__2_n_0 1 2 1 NJ 180
load net pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output[6]_i_12__2_n_0 -attr @name pe_output[6]_i_12__2_n_0 -attr @rip(#000000) 3 -pin pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output[6]_i_12__2 O -pin pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output_reg[6]_i_3 S[3]
netloc pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output[6]_i_12__2_n_0 1 3 1 NJ 220
load net pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output_reg[6]_i_3_n_0 -attr @name pe_output_reg[6]_i_3_n_0 -attr @rip(#000000) CO[3] -pin pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output_reg[14]_i_21 CI -pin pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output_reg[6]_i_3 CO[3]
netloc pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output_reg[6]_i_3_n_0 1 4 1 NJ 180
load net pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output_reg[14]_i_21_n_6 -attr @style dashed -attr @name pe_output_reg[14]_i_21_n_6 -attr @rip(#000000) O[1] -pin pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output[10]_i_10__2 I3 -pin pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output_reg[14]_i_21 O[1]
netloc pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output_reg[14]_i_21_n_6 1 5 1 NJ 220
load net pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output[10]_i_10__2_n_0 -attr @style dashed -attr @name pe_output[10]_i_10__2_n_0 -pin pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output[10]_i_10__2 O -pin pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output[10]_i_6__2 I1
netloc pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output[10]_i_10__2_n_0 1 6 1 NJ 180
load net pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output[10]_i_6__2_n_0 -attr @name pe_output[10]_i_6__2_n_0 -attr @rip(#000000) 3 -pin pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output[10]_i_6__2 O -pin pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output_reg[10]_i_1 S[3]
netloc pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output[10]_i_6__2_n_0 1 7 1 NJ 200
load net pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output_reg[10]_i_1_n_0 -attr @name pe_output_reg[10]_i_1_n_0 -attr @rip(#000000) CO[3] -pin pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output_reg[10]_i_1 CO[3] -pin pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output_reg[14]_i_1 CI
netloc pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output_reg[10]_i_1_n_0 1 8 1 NJ 160
load net pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output_reg[14]_i_1_n_0 -attr @name pe_output_reg[14]_i_1_n_0 -attr @rip(#000000) CO[3] -pin pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output_reg[14]_i_1 CO[3] -pin pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output_reg[15]_i_1 CI
netloc pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output_reg[14]_i_1_n_0 1 9 1 NJ 180
load net pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output_reg[15]_i_1_n_7 -attr @name pe_output_reg[15]_i_1_n_7 -attr @rip(#000000) O[0] -pin pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output_reg[15] D -pin pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output_reg[15]_i_1 O[0]
netloc pe_engine|genblk1[1].genblk1[2].pe_inst|pe_output_reg[15]_i_1_n_7 1 10 1 NJ 220
levelinfo -pg 1 0 10 2210
levelinfo -hier pe_engine * 20 *
levelinfo -hier pe_engine|genblk1[1].genblk1[2].pe_inst * 80 260 450 610 810 1050 1250 1420 1630 1840 2070 *
pagesize -pg 1 -db -bbox -sgen 0 0 2210 380
pagesize -hier pe_engine -db -bbox -sgen 10 40 2200 350
pagesize -hier pe_engine|genblk1[1].genblk1[2].pe_inst -db -bbox -sgen 20 80 2190 320
show
fullfit
#
# initialize ictrl to current module top work:top:NOFILE
ictrl init topinfo |

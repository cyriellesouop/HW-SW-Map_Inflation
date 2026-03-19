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
load symbol pe_wrapper work:pe_wrapper:NOFILE HIERBOX pin clk input.left pin m_axis_tready input.left pin m_axis_tvalid output.right pin p_0_in output.right pin pe_en_delayed input.left pin rstn input.left pinBus Q input.left [391:0] pinBus dataIn input.left [55:0] pinBus m_axis_tdata output.right [18:0] boxcolor 1 fillcolor 2 minwidth 13%
load symbol pe_16 work:pe_16:NOFILE HIERBOX pin clk input.left pin pe_en_reg input.left pin pe_input_reg_reg[0]_0 output.right pin pe_input_reg_reg[0]_1 output.right pin pe_input_reg_reg[0]_2 output.right pin pe_input_reg_reg[0]_3 output.right pin pe_input_reg_reg[0]_4 output.right pin pe_input_reg_reg[0]_5 output.right pin pe_input_reg_reg[2]_11 output.right pin pe_input_reg_reg[2]_12 output.right pin pe_input_reg_reg[2]_13 output.right pin pe_input_reg_reg[2]_14 output.right pin pe_input_reg_reg[2]_15 output.right pin pe_input_reg_reg[2]_16 output.right pin pe_input_reg_reg[2]_17 output.right pin pe_input_reg_reg[2]_18 output.right pin pe_input_reg_reg[2]_19 output.right pin pe_input_reg_reg[2]_20 output.right pin pe_input_reg_reg[2]_21 output.right pin pe_input_reg_reg[2]_22 output.right pin pe_input_reg_reg[2]_23 output.right pin pe_input_reg_reg[2]_24 output.right pin pe_input_reg_reg[2]_25 output.right pin pe_input_reg_reg[2]_26 output.right pin pe_input_reg_reg[2]_27 output.right pin pe_input_reg_reg[2]_28 output.right pin pe_input_reg_reg[3]_0 output.right pin pe_input_reg_reg[3]_1 output.right pin pe_input_reg_reg[3]_10 output.right pin pe_input_reg_reg[3]_11 output.right pin pe_input_reg_reg[3]_12 output.right pin pe_input_reg_reg[3]_13 output.right pin pe_input_reg_reg[3]_14 output.right pin pe_input_reg_reg[3]_15 output.right pin pe_input_reg_reg[3]_16 output.right pin pe_input_reg_reg[3]_17 output.right pin pe_input_reg_reg[3]_2 output.right pin pe_input_reg_reg[3]_3 output.right pin pe_input_reg_reg[3]_4 output.right pin pe_input_reg_reg[3]_5 output.right pin pe_input_reg_reg[3]_6 output.right pin pe_input_reg_reg[3]_7 output.right pin pe_input_reg_reg[3]_8 output.right pin pe_input_reg_reg[3]_9 output.right pin pe_input_reg_reg[4]_0 output.right pin pe_input_reg_reg[4]_1 output.right pin pe_input_reg_reg[4]_10 output.right pin pe_input_reg_reg[4]_11 output.right pin pe_input_reg_reg[4]_12 output.right pin pe_input_reg_reg[4]_13 output.right pin pe_input_reg_reg[4]_14 output.right pin pe_input_reg_reg[4]_15 output.right pin pe_input_reg_reg[4]_16 output.right pin pe_input_reg_reg[4]_17 output.right pin pe_input_reg_reg[4]_2 output.right pin pe_input_reg_reg[4]_3 output.right pin pe_input_reg_reg[4]_4 output.right pin pe_input_reg_reg[4]_5 output.right pin pe_input_reg_reg[4]_6 output.right pin pe_input_reg_reg[4]_7 output.right pin pe_input_reg_reg[4]_8 output.right pin pe_input_reg_reg[4]_9 output.right pin pe_input_reg_reg[5]_0 output.right pin pe_input_reg_reg[5]_1 output.right pin pe_input_reg_reg[5]_10 output.right pin pe_input_reg_reg[5]_11 output.right pin pe_input_reg_reg[5]_12 output.right pin pe_input_reg_reg[5]_13 output.right pin pe_input_reg_reg[5]_14 output.right pin pe_input_reg_reg[5]_15 output.right pin pe_input_reg_reg[5]_16 output.right pin pe_input_reg_reg[5]_17 output.right pin pe_input_reg_reg[5]_2 output.right pin pe_input_reg_reg[5]_3 output.right pin pe_input_reg_reg[5]_4 output.right pin pe_input_reg_reg[5]_5 output.right pin pe_input_reg_reg[5]_6 output.right pin pe_input_reg_reg[5]_7 output.right pin pe_input_reg_reg[5]_8 output.right pin pe_input_reg_reg[5]_9 output.right pin rstn input.left pinBus CO input.left [0:0] pinBus DI output.right [1:0] pinBus O input.left [1:0] pinBus Q output.right [7:0] pinBus S output.right [2:0] pinBus SR input.left [0:0] pinBus dataIn input.left [7:0] pinBus pe_input_reg_reg[2]_0 output.right [2:0] pinBus pe_input_reg_reg[2]_1 output.right [2:0] pinBus pe_input_reg_reg[2]_10 output.right [2:0] pinBus pe_input_reg_reg[2]_2 output.right [2:0] pinBus pe_input_reg_reg[2]_3 output.right [2:0] pinBus pe_input_reg_reg[2]_4 output.right [2:0] pinBus pe_input_reg_reg[2]_5 output.right [2:0] pinBus pe_input_reg_reg[2]_6 output.right [2:0] pinBus pe_input_reg_reg[2]_7 output.right [2:0] pinBus pe_input_reg_reg[2]_8 output.right [2:0] pinBus pe_input_reg_reg[2]_9 output.right [2:0] pinBus pe_input_reg_reg[6]_0 output.right [1:0] pinBus pe_input_reg_reg[6]_1 output.right [1:0] pinBus pe_input_reg_reg[6]_2 output.right [1:0] pinBus pe_input_reg_reg[6]_3 output.right [1:0] pinBus pe_input_reg_reg[6]_4 output.right [1:0] pinBus pe_input_reg_reg[7]_0 output.right [0:0] pinBus pe_input_reg_reg[7]_1 output.right [0:0] pinBus pe_input_reg_reg[7]_2 output.right [0:0] pinBus pe_input_reg_reg[7]_3 output.right [0:0] pinBus pe_input_reg_reg[7]_4 output.right [0:0] pinBus pe_input_reg_reg[7]_5 output.right [0:0] pinBus pe_output_reg[14]_0 input.left [7:0] pinBus pe_output_reg[14]_1 input.left [7:0] pinBus pe_output_reg[14]_10 input.left [0:0] pinBus pe_output_reg[14]_11 input.left [1:0] pinBus pe_output_reg[14]_12 input.left [1:0] pinBus pe_output_reg[14]_13 input.left [1:0] pinBus pe_output_reg[14]_14 input.left [1:0] pinBus pe_output_reg[14]_15 input.left [1:0] pinBus pe_output_reg[14]_2 input.left [7:0] pinBus pe_output_reg[14]_3 input.left [7:0] pinBus pe_output_reg[14]_4 input.left [7:0] pinBus pe_output_reg[14]_5 input.left [7:0] pinBus pe_output_reg[14]_6 input.left [0:0] pinBus pe_output_reg[14]_7 input.left [0:0] pinBus pe_output_reg[14]_8 input.left [0:0] pinBus pe_output_reg[14]_9 input.left [0:0] pinBus pe_output_reg[15]_0 output.right [15:0] pinBus pe_weight_reg_reg[7]_0 input.left [7:0] boxcolor 1 fillcolor 2 minwidth 13%
load symbol FDRE hdi_primitives GEN pin Q output.right pin C input.clk.left pin CE input.left pin D input.left pin R input.left fillcolor 1
load symbol pe_63 work:pe_63:NOFILE HIERBOX pin clk input.left pin pe_en_reg input.left pin pe_output0__0_carry__0_0 input.left pin pe_output0__0_carry__0_1 input.left pin pe_output0__0_carry__0_2 input.left pin pe_output0__0_carry__0_3 input.left pin pe_output0__30_carry__0_0 input.left pin pe_output0__30_carry__0_1 input.left pin pe_output0__30_carry__0_2 input.left pin pe_output0__30_carry__0_3 input.left pin pe_output_reg[10]_0 input.left pin pe_output_reg[10]_1 input.left pin pe_output_reg[10]_2 input.left pin pe_output_reg[10]_3 input.left pin pe_output_reg[14]_2 input.left pin rstn input.left pinBus Q output.right [7:0] pinBus SR input.left [0:0] pinBus pe_output0__60_carry_i_5__40_0 input.left [2:0] pinBus pe_output_reg[14]_0 input.left [1:0] pinBus pe_output_reg[14]_1 input.left [7:0] pinBus pe_output_reg[15]_0 output.right [15:0] pinBus pe_output_reg[15]_1 input.left [0:0] pinBus pe_output_reg[2]_0 input.left [2:0] pinBus pe_weight_reg_reg[5]_0 output.right [0:0] pinBus pe_weight_reg_reg[5]_1 output.right [1:0] pinBus pe_weight_reg_reg[7]_0 input.left [7:0] boxcolor 1 fillcolor 2 minwidth 13%
load symbol LUT6 hdi_primitives BOX pin O output.right pin I0 input.left pin I1 input.left pin I2 input.left pin I3 input.left pin I4 input.left pin I5 input.left fillcolor 1
load symbol CARRY4 hdi_primitives BOX pin CI input.left pin CYINIT input.left pinBus CO output.right [3:0] pinBus O output.right [3:0] pinBus DI input.left [3:0] pinBus S input.left [3:0] fillcolor 1
load symbol LUT4 hdi_primitives BOX pin O output.right pin I0 input.left pin I1 input.left pin I2 input.left pin I3 input.left fillcolor 1
load inst pe_engine pe_wrapper work:pe_wrapper:NOFILE -autohide -attr @cell(#000000) pe_wrapper -attr @fillcolor #fafafa -pinBusAttr Q @name Q[391:0] -pinBusAttr dataIn @name dataIn[55:0] -pinBusAttr m_axis_tdata @name m_axis_tdata[18:0] -pg 1 -lvl 1 -x 10 -y 70
load inst pe_engine|genblk1[0].genblk1[5].pe_inst pe_16 work:pe_16:NOFILE -hier pe_engine -autohide -attr @name genblk1[0].genblk1[5].pe_inst -attr @cell(#000000) pe_16 -attr @fillcolor #fafafa -pinBusAttr CO @name CO -pinBusAttr DI @name DI[1:0] -pinBusAttr O @name O[1:0] -pinBusAttr Q @name Q[7:0] -pinBusAttr S @name S[2:0] -pinBusAttr SR @name SR -pinBusAttr dataIn @name dataIn[7:0] -pinBusAttr pe_input_reg_reg[2]_0 @name pe_input_reg_reg[2]_0[2:0] -pinBusAttr pe_input_reg_reg[2]_1 @name pe_input_reg_reg[2]_1[2:0] -pinBusAttr pe_input_reg_reg[2]_10 @name pe_input_reg_reg[2]_10[2:0] -pinBusAttr pe_input_reg_reg[2]_2 @name pe_input_reg_reg[2]_2[2:0] -pinBusAttr pe_input_reg_reg[2]_3 @name pe_input_reg_reg[2]_3[2:0] -pinBusAttr pe_input_reg_reg[2]_4 @name pe_input_reg_reg[2]_4[2:0] -pinBusAttr pe_input_reg_reg[2]_5 @name pe_input_reg_reg[2]_5[2:0] -pinBusAttr pe_input_reg_reg[2]_6 @name pe_input_reg_reg[2]_6[2:0] -pinBusAttr pe_input_reg_reg[2]_7 @name pe_input_reg_reg[2]_7[2:0] -pinBusAttr pe_input_reg_reg[2]_8 @name pe_input_reg_reg[2]_8[2:0] -pinBusAttr pe_input_reg_reg[2]_9 @name pe_input_reg_reg[2]_9[2:0] -pinBusAttr pe_input_reg_reg[6]_0 @name pe_input_reg_reg[6]_0[1:0] -pinBusAttr pe_input_reg_reg[6]_1 @name pe_input_reg_reg[6]_1[1:0] -pinBusAttr pe_input_reg_reg[6]_2 @name pe_input_reg_reg[6]_2[1:0] -pinBusAttr pe_input_reg_reg[6]_3 @name pe_input_reg_reg[6]_3[1:0] -pinBusAttr pe_input_reg_reg[6]_4 @name pe_input_reg_reg[6]_4[1:0] -pinBusAttr pe_input_reg_reg[7]_0 @name pe_input_reg_reg[7]_0 -pinBusAttr pe_input_reg_reg[7]_1 @name pe_input_reg_reg[7]_1 -pinBusAttr pe_input_reg_reg[7]_2 @name pe_input_reg_reg[7]_2 -pinBusAttr pe_input_reg_reg[7]_3 @name pe_input_reg_reg[7]_3 -pinBusAttr pe_input_reg_reg[7]_4 @name pe_input_reg_reg[7]_4 -pinBusAttr pe_input_reg_reg[7]_5 @name pe_input_reg_reg[7]_5 -pinBusAttr pe_output_reg[14]_0 @name pe_output_reg[14]_0[7:0] -pinBusAttr pe_output_reg[14]_1 @name pe_output_reg[14]_1[7:0] -pinBusAttr pe_output_reg[14]_10 @name pe_output_reg[14]_10 -pinBusAttr pe_output_reg[14]_11 @name pe_output_reg[14]_11[1:0] -pinBusAttr pe_output_reg[14]_12 @name pe_output_reg[14]_12[1:0] -pinBusAttr pe_output_reg[14]_13 @name pe_output_reg[14]_13[1:0] -pinBusAttr pe_output_reg[14]_14 @name pe_output_reg[14]_14[1:0] -pinBusAttr pe_output_reg[14]_15 @name pe_output_reg[14]_15[1:0] -pinBusAttr pe_output_reg[14]_2 @name pe_output_reg[14]_2[7:0] -pinBusAttr pe_output_reg[14]_3 @name pe_output_reg[14]_3[7:0] -pinBusAttr pe_output_reg[14]_4 @name pe_output_reg[14]_4[7:0] -pinBusAttr pe_output_reg[14]_5 @name pe_output_reg[14]_5[7:0] -pinBusAttr pe_output_reg[14]_6 @name pe_output_reg[14]_6 -pinBusAttr pe_output_reg[14]_7 @name pe_output_reg[14]_7 -pinBusAttr pe_output_reg[14]_8 @name pe_output_reg[14]_8 -pinBusAttr pe_output_reg[14]_9 @name pe_output_reg[14]_9 -pinBusAttr pe_output_reg[15]_0 @name pe_output_reg[15]_0[15:0] -pinBusAttr pe_weight_reg_reg[7]_0 @name pe_weight_reg_reg[7]_0[7:0] -pg 1 -lvl 1 -x 40 -y 110
load inst pe_engine|genblk1[0].genblk1[5].pe_inst|pe_input_reg_reg[3] FDRE hdi_primitives -hier pe_engine|genblk1[0].genblk1[5].pe_inst -attr @name pe_input_reg_reg[3] -attr @cell(#000000) FDRE -pg 1 -lvl 1 -x 100 -y 160
load inst pe_engine|genblk1[6].genblk1[5].pe_inst pe_63 work:pe_63:NOFILE -hier pe_engine -autohide -attr @name genblk1[6].genblk1[5].pe_inst -attr @cell(#000000) pe_63 -attr @fillcolor #fafafa -pinBusAttr Q @name Q[7:0] -pinBusAttr SR @name SR -pinBusAttr pe_output0__60_carry_i_5__40_0 @name pe_output0__60_carry_i_5__40_0[2:0] -pinBusAttr pe_output_reg[14]_0 @name pe_output_reg[14]_0[1:0] -pinBusAttr pe_output_reg[14]_1 @name pe_output_reg[14]_1[7:0] -pinBusAttr pe_output_reg[15]_0 @name pe_output_reg[15]_0[15:0] -pinBusAttr pe_output_reg[15]_1 @name pe_output_reg[15]_1 -pinBusAttr pe_output_reg[2]_0 @name pe_output_reg[2]_0[2:0] -pinBusAttr pe_weight_reg_reg[5]_0 @name pe_weight_reg_reg[5]_0 -pinBusAttr pe_weight_reg_reg[5]_1 @name pe_weight_reg_reg[5]_1[1:0] -pinBusAttr pe_weight_reg_reg[7]_0 @name pe_weight_reg_reg[7]_0[7:0] -pg 1 -lvl 2 -x 490 -y 130
load inst pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output0__0_carry__0_i_2__40 LUT6 hdi_primitives -hier pe_engine|genblk1[6].genblk1[5].pe_inst -attr @name pe_output0__0_carry__0_i_2__40 -attr @cell(#000000) LUT6 -pg 1 -lvl 1 -x 620 -y 130
load inst pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output0__0_carry__0_i_6__40 LUT6 hdi_primitives -hier pe_engine|genblk1[6].genblk1[5].pe_inst -attr @name pe_output0__0_carry__0_i_6__40 -attr @cell(#000000) LUT6 -pg 1 -lvl 2 -x 900 -y 170
load inst pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output0__0_carry__0 CARRY4 hdi_primitives -hier pe_engine|genblk1[6].genblk1[5].pe_inst -attr @name pe_output0__0_carry__0 -attr @cell(#000000) CARRY4 -pinBusAttr CO @name CO[3:0] -pinBusAttr O @name O[3:0] -pinBusAttr DI @name DI[3:0] -pinBusAttr S @name S[3:0] -pg 1 -lvl 3 -x 1110 -y 150
load inst pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output0__0_carry__1 CARRY4 hdi_primitives -hier pe_engine|genblk1[6].genblk1[5].pe_inst -attr @name pe_output0__0_carry__1 -attr @cell(#000000) CARRY4 -pinBusAttr CO @name CO[3:0] -pinBusAttr O @name O[3:0] -pinBusAttr DI @name DI[3:0] -pinBusAttr S @name S[3:0] -pg 1 -lvl 4 -x 1320 -y 170
load inst pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output0__60_carry__0_i_15__40 LUT4 hdi_primitives -hier pe_engine|genblk1[6].genblk1[5].pe_inst -attr @name pe_output0__60_carry__0_i_15__40 -attr @cell(#000000) LUT4 -pg 1 -lvl 5 -x 1610 -y 190
load inst pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output0__60_carry__1_i_4__40 LUT4 hdi_primitives -hier pe_engine|genblk1[6].genblk1[5].pe_inst -attr @name pe_output0__60_carry__1_i_4__40 -attr @cell(#000000) LUT4 -pg 1 -lvl 6 -x 1900 -y 150
load inst pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output0__60_carry__1 CARRY4 hdi_primitives -hier pe_engine|genblk1[6].genblk1[5].pe_inst -attr @name pe_output0__60_carry__1 -attr @cell(#000000) CARRY4 -pinBusAttr CO @name CO[3:0] -pinBusAttr O @name O[3:0] -pinBusAttr DI @name DI[3:0] -pinBusAttr S @name S[3:0] -pg 1 -lvl 7 -x 2120 -y 130
load inst pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output0__60_carry__2 CARRY4 hdi_primitives -hier pe_engine|genblk1[6].genblk1[5].pe_inst -attr @name pe_output0__60_carry__2 -attr @cell(#000000) CARRY4 -pinBusAttr CO @name CO[3:0] -pinBusAttr CO @attr n/c -pinBusAttr O @name O[3:0] -pinBusAttr DI @name DI[3:0] -pinBusAttr S @name S[3:0] -pg 1 -lvl 8 -x 2350 -y 150
load inst pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output_reg[15] FDRE hdi_primitives -hier pe_engine|genblk1[6].genblk1[5].pe_inst -attr @name pe_output_reg[15] -attr @cell(#000000) FDRE -pg 1 -lvl 9 -x 2590 -y 190
load net pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output_reg[14]_1[3] -attr @style dashed -attr @name pe_output_reg[14]_1[3] -attr @rip(#000000) pe_output_reg[14]_1[3] -hierPin pe_engine|genblk1[6].genblk1[5].pe_inst pe_output_reg[14]_1[3] -pin pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output0__0_carry__0_i_2__40 I1
netloc pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output_reg[14]_1[3] 1 0 1 NJ 160
load net pe_engine|genblk1[0].genblk1[5].pe_inst_n_4 -attr @style dashed -attr @name genblk1[0].genblk1[5].pe_inst_n_4 -attr @rip(#000000) Q[3] -pin pe_engine|genblk1[0].genblk1[5].pe_inst Q[3] -pin pe_engine|genblk1[6].genblk1[5].pe_inst pe_output_reg[14]_1[3]
netloc pe_engine|genblk1[0].genblk1[5].pe_inst_n_4 1 1 1 NJ 160
load net pe_engine|genblk1[0].genblk1[5].pe_inst|Q[3] -attr @style dashed -attr @name Q[3] -attr @rip(#000000) 3 -hierPin pe_engine|genblk1[0].genblk1[5].pe_inst Q[3] -pin pe_engine|genblk1[0].genblk1[5].pe_inst|pe_input_reg_reg[3] Q
netloc pe_engine|genblk1[0].genblk1[5].pe_inst|Q[3] 1 1 1 NJ 160
load net pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output0__0_carry__0_i_2__40_n_0 -attr @style dashed -attr @name pe_output0__0_carry__0_i_2__40_n_0 -attr @rip(#000000) 2 -pin pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output0__0_carry__0_i_2__40 O -pin pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output0__0_carry__0_i_6__40 I0
netloc pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output0__0_carry__0_i_2__40_n_0 1 1 1 NJ 180
load net pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output0__0_carry__0_i_6__40_n_0 -attr @name pe_output0__0_carry__0_i_6__40_n_0 -attr @rip(#000000) 2 -pin pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output0__0_carry__0 S[2] -pin pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output0__0_carry__0_i_6__40 O
netloc pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output0__0_carry__0_i_6__40_n_0 1 2 1 NJ 220
load net pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output0__0_carry__0_n_0 -attr @name pe_output0__0_carry__0_n_0 -attr @rip(#000000) CO[3] -pin pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output0__0_carry__0 CO[3] -pin pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output0__0_carry__1 CI
netloc pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output0__0_carry__0_n_0 1 3 1 NJ 180
load net pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output0__0_carry__1_n_6 -attr @style dashed -attr @name pe_output0__0_carry__1_n_6 -attr @rip(#000000) O[1] -pin pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output0__0_carry__1 O[1] -pin pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output0__60_carry__0_i_15__40 I1
netloc pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output0__0_carry__1_n_6 1 4 1 NJ 220
load net pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output0__60_carry__0_i_15__40_n_0 -attr @style dashed -attr @name pe_output0__60_carry__0_i_15__40_n_0 -pin pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output0__60_carry__0_i_15__40 O -pin pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output0__60_carry__1_i_4__40 I3
netloc pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output0__60_carry__0_i_15__40_n_0 1 5 1 NJ 220
load net pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output0__60_carry__1_i_4__40_n_0 -attr @name pe_output0__60_carry__1_i_4__40_n_0 -attr @rip(#000000) 0 -pin pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output0__60_carry__1 DI[0] -pin pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output0__60_carry__1_i_4__40 O
netloc pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output0__60_carry__1_i_4__40_n_0 1 6 1 NJ 180
load net pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output0__60_carry__1_n_0 -attr @name pe_output0__60_carry__1_n_0 -attr @rip(#000000) CO[3] -pin pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output0__60_carry__1 CO[3] -pin pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output0__60_carry__2 CI
netloc pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output0__60_carry__1_n_0 1 7 1 NJ 160
load net pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output0__60_carry__2_n_7 -attr @name pe_output0__60_carry__2_n_7 -attr @rip(#000000) O[0] -pin pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output0__60_carry__2 O[0] -pin pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output_reg[15] D
netloc pe_engine|genblk1[6].genblk1[5].pe_inst|pe_output0__60_carry__2_n_7 1 8 1 NJ 200
levelinfo -pg 1 0 10 2730
levelinfo -hier pe_engine * 40 490 *
levelinfo -hier pe_engine|genblk1[0].genblk1[5].pe_inst * 100 *
levelinfo -hier pe_engine|genblk1[6].genblk1[5].pe_inst * 620 900 1110 1320 1610 1900 2120 2350 2590 *
pagesize -pg 1 -db -bbox -sgen 0 0 2730 380
pagesize -hier pe_engine -db -bbox -sgen 10 40 2720 350
pagesize -hier pe_engine|genblk1[0].genblk1[5].pe_inst -db -bbox -sgen 40 80 240 240
pagesize -hier pe_engine|genblk1[6].genblk1[5].pe_inst -db -bbox -sgen 490 100 2710 320
show
fullfit
#
# initialize ictrl to current module top work:top:NOFILE
ictrl init topinfo |

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
load symbol axis_unpack_data work:axis_unpack_data:NOFILE HIERBOX pin accumulated_valid input.left pin clk input.left pin lopt output.right pin lopt_1 output.right pin lopt_2 output.right pin lopt_3 output.right pin lopt_4 output.right pin lopt_5 output.right pin lopt_6 output.right pin lopt_7 output.right pin m_axis_tready input.left pin pe_en_delayed input.left pin pipe_flushing input.left pin pipe_reg[10][0] output.right pin rd_addr_reg[1] output.right pin rd_cnt_reg input.left pin rstn input.left pin wr_cnt_reg output.right pinBus Q input.left [23:0] pinBus fifo_m_tdata output.right [23:0] boxcolor 1 fillcolor 2 minwidth 13%
load symbol fifo_axis_1 work:fifo_axis_1:NOFILE HIERBOX pin accumulated_valid input.left pin clk input.left pin dataOut_reg[7] input.left pin lopt input.left pin lopt_1 input.left pin lopt_2 input.left pin lopt_3 input.left pin lopt_4 input.left pin lopt_5 input.left pin lopt_6 input.left pin m_axis_tready input.left pin pe_en_delayed input.left pin rd_addr_reg[1] output.right pin rd_addr_reg[1]_0 output.right pin rd_cnt_reg input.left pin rstn input.left pin wr_cnt_reg input.left pinBus E input.left [0:0] pinBus Q input.left [7:0] pinBus fifo_m_tdata output.right [7:0] boxcolor 1 fillcolor 2 minwidth 13%
load symbol fifo work:fifo:NOFILE HIERBOX pin accumulated_valid input.left pin clk input.left pin dataOut_reg[7]_0 input.left pin lopt input.left pin lopt_1 input.left pin lopt_2 input.left pin lopt_3 input.left pin lopt_4 input.left pin lopt_5 input.left pin lopt_6 input.left pin m_axis_tready input.left pin pe_en_delayed input.left pin rd_addr_reg[1]_0 output.right pin rd_addr_reg[1]_1 output.right pin rd_cnt_reg_0 input.left pin rstn input.left pin wr_cnt_reg_0 input.left pinBus E input.left [0:0] pinBus Q input.left [7:0] pinBus fifo_m_tdata output.right [7:0] boxcolor 1 fillcolor 2 minwidth 13%
load symbol FDRE hdi_primitives GEN pin Q output.right pin C input.clk.left pin CE input.left pin D input.left pin R input.left fillcolor 1
load symbol LUT6 hdi_primitives BOX pin O output.right pin I0 input.left pin I1 input.left pin I2 input.left pin I3 input.left pin I4 input.left pin I5 input.left fillcolor 1
load symbol fifo_axis work:fifo_axis:NOFILE HIERBOX pin accumulated_valid input.left pin clk input.left pin lopt output.right pin lopt_1 output.right pin lopt_2 output.right pin lopt_3 output.right pin lopt_4 output.right pin lopt_5 output.right pin m_axis_tready input.left pin m_axis_tvalid_reg output.right pin pe_en_delayed input.left pin rd_addr_reg[1] output.right pin rd_cnt_reg input.left pin rstn input.left pin wr_addr_reg[0] input.left pin wr_addr_reg[0]_0 input.left pin wr_cnt_reg output.right pinBus E output.right [0:0] pinBus Q input.left [7:0] pinBus fifo_m_tdata output.right [7:0] boxcolor 1 fillcolor 2 minwidth 13%
load symbol fifo_3 work:fifo_3:NOFILE HIERBOX pin accumulated_valid input.left pin clk input.left pin lopt output.right pin lopt_1 output.right pin lopt_2 output.right pin lopt_3 output.right pin lopt_4 output.right pin lopt_5 output.right pin m_axis_tready input.left pin m_axis_tvalid_reg output.right pin pe_en_delayed input.left pin rd_addr_reg[1]_0 output.right pin rd_cnt_reg_0 input.left pin rstn input.left pin wr_addr_reg[0]_0 input.left pin wr_addr_reg[0]_1 input.left pin wr_cnt_reg_0 output.right pinBus E output.right [0:0] pinBus Q input.left [7:0] pinBus fifo_m_tdata output.right [7:0] boxcolor 1 fillcolor 2 minwidth 13%
load symbol LUT2 hdi_primitives BOX pin O output.right pin I0 input.left pin I1 input.left fillcolor 1
load symbol RAM32X1D {hdi_primitives:netlist:no file specified} HIERBOX pin DPO output.right pin SPO output.right pin A0 input.left pin A1 input.left pin A2 input.left pin A3 input.left pin A4 input.left pin D input.left pin DPRA0 input.left pin DPRA1 input.left pin DPRA2 input.left pin DPRA3 input.left pin DPRA4 input.left pin WCLK input.left pin WE input.left fillcolor 2
load symbol RAMD32 hdi_primitives BOX pin O output.right pin CLK input.left pin I input.left pin RADR0 input.left pin RADR1 input.left pin RADR2 input.left pin RADR3 input.left pin RADR4 input.left pin WADR0 input.left pin WADR1 input.left pin WADR2 input.left pin WADR3 input.left pin WADR4 input.left pin WE input.left fillcolor 1
load inst unpacker axis_unpack_data work:axis_unpack_data:NOFILE -autohide -attr @cell(#000000) axis_unpack_data -attr @fillcolor #fafafa -pinBusAttr Q @name Q[23:0] -pinBusAttr fifo_m_tdata @name fifo_m_tdata[23:0] -pg 1 -lvl 1 -x 10 -y 70
load inst unpacker|genblk1[2].fifo_inst fifo_axis_1 work:fifo_axis_1:NOFILE -hier unpacker -autohide -attr @name genblk1[2].fifo_inst -attr @cell(#000000) fifo_axis_1 -attr @fillcolor #fafafa -pinBusAttr E @name E -pinBusAttr Q @name Q[7:0] -pinBusAttr fifo_m_tdata @name fifo_m_tdata[7:0] -pg 1 -lvl 1 -x 20 -y 280
load inst unpacker|genblk1[2].fifo_inst|fifo_inst fifo work:fifo:NOFILE -hier unpacker|genblk1[2].fifo_inst -autohide -attr @name fifo_inst -attr @cell(#000000) fifo -attr @fillcolor #fafafa -pinBusAttr E @name E -pinBusAttr Q @name Q[7:0] -pinBusAttr fifo_m_tdata @name fifo_m_tdata[7:0] -pg 1 -lvl 1 -x 30 -y 320
load inst unpacker|genblk1[2].fifo_inst|fifo_inst|wr_addr_reg[1] FDRE hdi_primitives -hier unpacker|genblk1[2].fifo_inst|fifo_inst -attr @name wr_addr_reg[1] -attr @cell(#000000) FDRE -pg 1 -lvl 1 -x 80 -y 370
load inst unpacker|genblk1[2].fifo_inst|fifo_inst|wr_addr[1]_i_5 LUT6 hdi_primitives -hier unpacker|genblk1[2].fifo_inst|fifo_inst -attr @name wr_addr[1]_i_5 -attr @cell(#000000) LUT6 -pg 1 -lvl 2 -x 230 -y 340
load inst unpacker|genblk1[0].fifo_inst fifo_axis work:fifo_axis:NOFILE -hier unpacker -autohide -attr @name genblk1[0].fifo_inst -attr @cell(#000000) fifo_axis -attr @fillcolor #fafafa -pinBusAttr E @name E -pinBusAttr Q @name Q[7:0] -pinBusAttr fifo_m_tdata @name fifo_m_tdata[7:0] -pg 1 -lvl 2 -x 760 -y 100
load inst unpacker|genblk1[0].fifo_inst|fifo_inst fifo_3 work:fifo_3:NOFILE -hier unpacker|genblk1[0].fifo_inst -autohide -attr @name fifo_inst -attr @cell(#000000) fifo_3 -attr @fillcolor #fafafa -pinBusAttr E @name E -pinBusAttr Q @name Q[7:0] -pinBusAttr fifo_m_tdata @name fifo_m_tdata[7:0] -pg 1 -lvl 1 -x 910 -y 130
load inst unpacker|genblk1[0].fifo_inst|fifo_inst|i_2_LOPT_REMAP LUT2 hdi_primitives -hier unpacker|genblk1[0].fifo_inst|fifo_inst -attr @name i_2_LOPT_REMAP -attr @cell(#000000) LUT2 -pg 1 -lvl 1 -x 980 -y 380
load inst unpacker|genblk1[0].fifo_inst|fifo_inst|i_0_LOPT_REMAP LUT6 hdi_primitives -hier unpacker|genblk1[0].fifo_inst|fifo_inst -attr @name i_0_LOPT_REMAP -attr @cell(#000000) LUT6 -pg 1 -lvl 2 -x 1140 -y 360
load inst unpacker|genblk1[0].fifo_inst|fifo_inst|MEM_reg_0_3_6_7 RAM32X1D {hdi_primitives:netlist:no file specified} -hier unpacker|genblk1[0].fifo_inst|fifo_inst -autohide -attr @name MEM_reg_0_3_6_7 -attr @cell(#000000) RAM32X1D -attr @fillcolor #fafafa -pinAttr SPO @attr n/c -pg 1 -lvl 3 -x 1300 -y 160
load inst unpacker|genblk1[0].fifo_inst|fifo_inst|MEM_reg_0_3_6_7|DP RAMD32 hdi_primitives -hier unpacker|genblk1[0].fifo_inst|fifo_inst|MEM_reg_0_3_6_7 -attr @name DP -attr @cell(#000000) RAMD32 -pg 1 -lvl 1 -x 1340 -y 160
load net unpacker|genblk1[2].fifo_inst|fifo_inst|wr_addr[1] -attr @style dashed -attr @name wr_addr[1] -attr @rip(#000000) 1 -pin unpacker|genblk1[2].fifo_inst|fifo_inst|wr_addr[1]_i_5 I1 -pin unpacker|genblk1[2].fifo_inst|fifo_inst|wr_addr_reg[1] Q
netloc unpacker|genblk1[2].fifo_inst|fifo_inst|wr_addr[1] 1 1 1 NJ 370
load net unpacker|genblk1[0].fifo_inst|fifo_inst|wr_addr_reg[0]_1 -attr @style dashed -attr @name wr_addr_reg[0]_1 -hierPin unpacker|genblk1[0].fifo_inst|fifo_inst wr_addr_reg[0]_1 -pin unpacker|genblk1[0].fifo_inst|fifo_inst|i_2_LOPT_REMAP I0
netloc unpacker|genblk1[0].fifo_inst|fifo_inst|wr_addr_reg[0]_1 1 0 1 NJ 390
load net unpacker|genblk1[0].fifo_inst|wr_addr_reg[0]_0 -attr @name wr_addr_reg[0]_0 -hierPin unpacker|genblk1[0].fifo_inst wr_addr_reg[0]_0 -pin unpacker|genblk1[0].fifo_inst|fifo_inst wr_addr_reg[0]_1
netloc unpacker|genblk1[0].fifo_inst|wr_addr_reg[0]_0 1 0 1 NJ 390
load net unpacker|genblk1[2].fifo_inst_n_1 -attr @style dashed -attr @name genblk1[2].fifo_inst_n_1 -pin unpacker|genblk1[0].fifo_inst wr_addr_reg[0]_0 -pin unpacker|genblk1[2].fifo_inst rd_addr_reg[1]_0
netloc unpacker|genblk1[2].fifo_inst_n_1 1 1 1 NJ 390
load net unpacker|genblk1[2].fifo_inst|rd_addr_reg[1]_0 -attr @name rd_addr_reg[1]_0 -hierPin unpacker|genblk1[2].fifo_inst rd_addr_reg[1]_0 -pin unpacker|genblk1[2].fifo_inst|fifo_inst rd_addr_reg[1]_1
netloc unpacker|genblk1[2].fifo_inst|rd_addr_reg[1]_0 1 1 1 NJ 390
load net unpacker|genblk1[2].fifo_inst|fifo_inst|rd_addr_reg[1]_1 -attr @style dashed -attr @name rd_addr_reg[1]_1 -hierPin unpacker|genblk1[2].fifo_inst|fifo_inst rd_addr_reg[1]_1 -pin unpacker|genblk1[2].fifo_inst|fifo_inst|wr_addr[1]_i_5 O
netloc unpacker|genblk1[2].fifo_inst|fifo_inst|rd_addr_reg[1]_1 1 2 1 NJ 390
load net unpacker|genblk1[0].fifo_inst|fifo_inst|i_2/O_n -attr @name i_2/O_n -pin unpacker|genblk1[0].fifo_inst|fifo_inst|i_0_LOPT_REMAP I1 -pin unpacker|genblk1[0].fifo_inst|fifo_inst|i_2_LOPT_REMAP O
netloc unpacker|genblk1[0].fifo_inst|fifo_inst|i_2/O_n 1 1 1 NJ 390
load net unpacker|genblk1[0].fifo_inst|fifo_inst|MEM_reg_0_3_6_7|WE -attr @style dashed -attr @name WE -hierPin unpacker|genblk1[0].fifo_inst|fifo_inst|MEM_reg_0_3_6_7 WE -pin unpacker|genblk1[0].fifo_inst|fifo_inst|MEM_reg_0_3_6_7|DP WE
netloc unpacker|genblk1[0].fifo_inst|fifo_inst|MEM_reg_0_3_6_7|WE 1 0 1 NJ 410
load net unpacker|genblk1[0].fifo_inst|fifo_inst|m_axis_tvalid_reg -attr @style dashed -attr @name m_axis_tvalid_reg -pin unpacker|genblk1[0].fifo_inst|fifo_inst|MEM_reg_0_3_6_7 WE -pin unpacker|genblk1[0].fifo_inst|fifo_inst|i_0_LOPT_REMAP O
netloc unpacker|genblk1[0].fifo_inst|fifo_inst|m_axis_tvalid_reg 1 2 1 NJ 410
levelinfo -pg 1 0 10 1490
levelinfo -hier unpacker * 20 760 *
levelinfo -hier unpacker|genblk1[2].fifo_inst * 30 *
levelinfo -hier unpacker|genblk1[2].fifo_inst|fifo_inst * 80 230 *
levelinfo -hier unpacker|genblk1[0].fifo_inst * 910 *
levelinfo -hier unpacker|genblk1[0].fifo_inst|fifo_inst * 980 1140 1300 *
levelinfo -hier unpacker|genblk1[0].fifo_inst|fifo_inst|MEM_reg_0_3_6_7 * 1340 *
pagesize -pg 1 -db -bbox -sgen 0 0 1490 600
pagesize -hier unpacker -db -bbox -sgen 10 40 1480 570
pagesize -hier unpacker|genblk1[2].fifo_inst -db -bbox -sgen 20 250 500 520
pagesize -hier unpacker|genblk1[2].fifo_inst|fifo_inst -db -bbox -sgen 30 290 350 490
pagesize -hier unpacker|genblk1[0].fifo_inst -db -bbox -sgen 760 70 1470 540
pagesize -hier unpacker|genblk1[0].fifo_inst|fifo_inst -db -bbox -sgen 910 100 1460 510
pagesize -hier unpacker|genblk1[0].fifo_inst|fifo_inst|MEM_reg_0_3_6_7 -db -bbox -sgen 1300 130 1450 450
show
fullfit
#
# initialize ictrl to current module top work:top:NOFILE
ictrl init topinfo |

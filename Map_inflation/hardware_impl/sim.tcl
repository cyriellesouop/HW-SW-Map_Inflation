open_saif myTop.saif
log_saif /tb_top2/DUT/*
log_wave -r *
run -all
close_saif
quit


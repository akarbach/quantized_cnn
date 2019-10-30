vcom -work work  /home/yyevgeny/hdd/projects/dram_top/dram_models/dpram4096x36_timingP.vhd
vcom -work work  /home/yyevgeny/hdd/projects/dram_top/dram_models/dpram4096x36.vhd

vcom -work work  ConvLayer_cntr.vhd
vcom -work work  ../cnn_1/ConvLayer_calc.vhd
vcom -work work  ConvLayer_1CE_top.vhd

vcom -work work  ConvLayer_1CE_top_tb.vhd
vsim work.ConvLayer_1CE_top_tb
do wave.do
run 800ns

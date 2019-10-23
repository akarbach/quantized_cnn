vcom -2008 -work work  ConvLayer_cntr.vhd
vcom -2008 -work work  ../cnn_1/ConvLayer_calc.vhd
vcom -2008 -work work  ConvLayer_1CE_top.vhd

vcom -2008 -work work  ConvLayer_1CE_top_tb.vhd
vsim work.ConvLayer_1CE_top_tb
do wave.do
run 8000ns

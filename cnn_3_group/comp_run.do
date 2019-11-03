vcom -work work  ConvLayer_types_package.vhd
vcom -work work  ../cnn_1/ConvLayer_calc.vhd
vcom -work work  ../multi_adder/multi_adder.vhd
vcom -work work  ConvLayer_grp.vhd

vcom -work work  ConvLayer_grp_tb.vhd
vsim work.ConvLayer_grp_tb
do wave.do
run 800ns

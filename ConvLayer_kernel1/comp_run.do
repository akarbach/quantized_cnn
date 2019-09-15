vcom -2008 -work work  ConvLayer_types_package.vhd
vcom -2008 -work work  ../multi_adder/multi_adder.vhd

vcom -2008 -work work  ../multiplier_parallel/mult.vhd
vcom -2008 -work work  ../multiplier_parallel/generic_mult.vhd
vcom -2008 -work work  ConvLayer_kernel1.vhd
vcom -2008 -work work  ConvLayer_kernel1_tb.vhd
vsim work.ConvLayer_kernel1_tb
do wave.do
run 4000ns

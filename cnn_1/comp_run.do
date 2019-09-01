vcom -2008 -work work  ConvLayer_types_package.vhd
vcom -2008 -work work  ../multi_adder/multi_adder.vhd
vcom -2008 -work work  ../multiplier_parallel/mult.vhd
vcom -2008 -work work  ../multiplier_parallel/generic_mult.vhd
vcom -2008 -work work  ConvLayer_data_gen.vhd
vcom -2008 -work work  ConvLayer_weight_gen.vhd
vcom -2008 -work work  ConvLayer_calc.vhd
vcom -2008 -work work  ConvLayer.vhd
vcom -2008 -work work  ConvLayer_tb.vhd
vsim work.ConvLayer_tb
do wave.do
run 4000ns

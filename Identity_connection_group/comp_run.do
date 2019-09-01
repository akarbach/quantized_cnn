vcom -2008 -work work  ../cnn_1/ConvLayer_types_package.vhd
vcom -2008 -work work  ../multi_adder/multi_adder.vhd
vcom -2008 -work work  ../multiplier_parallel/mult.vhd
vcom -2008 -work work  ../multiplier_parallel/generic_mult.vhd
vcom -2008 -work work  ../Fifo/Fifo.vhd
vcom -2008 -work work  ../cnn_1/ConvLayer_data_gen.vhd
vcom -2008 -work work  ../cnn_1/ConvLayer_weight_gen.vhd
vcom -2008 -work work  ../cnn_1/ConvLayer_calc.vhd
vcom -2008 -work work  ../cnn_1/ConvLayer.vhd

vcom -2008 -work work  ../pooling_NxN/Max3.vhd
vcom -2008 -work work  ../pooling_NxN/Pooling_calc.vhd
vcom -2008 -work work  ../pooling_NxN/Pooling_kernel_top.vhd

vcom -2008 -work work  ../Identity_connection/Identity_connection.vhd
vcom -2008 -work work  Identity_connection_group.vhd
vcom -2008 -work work  Identity_connection_group_tb.vhd
vsim work.Identity_connection_group_tb
do wave.do
run 20000ns

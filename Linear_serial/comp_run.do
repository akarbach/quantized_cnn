vcom -2008 -work work  ../cnn_1/ConvLayer_types_package.vhd
vcom -2008 -work work  ../multiplier_parallel/mult.vhd
vcom -2008 -work work  ../multiplier_parallel/generic_mult.vhd
vcom -2008 -work work  Linear_serial.vhd
vcom -2008 -work work  Linear_serial_tb.vhd
vsim work.Linear_serial_tb
do wave.do
run 1000ns

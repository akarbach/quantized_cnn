vcom -2008 -work work  ../cnn_1/ConvLayer_types_package.vhd

vcom -2008 -work work  Pseudorandom.vhd
vcom -2008 -work work  Pseudorandom_tb.vhd

vsim work.Pseudorandom_tb
do wave.do
run 10000ns

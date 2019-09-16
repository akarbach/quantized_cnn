vcom -2008 -work work  ../cnn_1/ConvLayer_types_package.vhd
vcom -2008 -work work  ../PCA/PCA_pixel.vhd

vcom -2008 -work work  ../multi_adder/multi_adder.vhd
vcom -2008 -work work  ../multiplier_parallel/mult.vhd
vcom -2008 -work work  ../multiplier_parallel/generic_mult.vhd
vcom -2008 -work work  ../cnn_1/ConvLayer_data_gen.vhd
vcom -2008 -work work  ../cnn_1/ConvLayer_weight_gen.vhd
vcom -2008 -work work  ../cnn_1/ConvLayer_calc.vhd
vcom -2008 -work work  ../cnn_1/ConvLayer_paralel_w.vhd

vcom -2008 -work work  ../Fifo/Fifo.vhd

vcom -2008 -work work  ../Huffman_code/Huffman.vhd

vcom -2008 -work work  Entropy_encoding.vhd
vcom -2008 -work work  Entropy_encoding_tb.vhd
vsim work.Entropy_encoding_tb
do wave.do
run 3000ns

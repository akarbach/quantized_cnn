vcom -93 -work work  ../binary_adder/multROM.vhd
vcom -93 -work work  ../Fifo/Fifo.vhd
vcom -93 -work work  ../binary_adder/Binary_adder8.vhd 
vcom -93 -work work  ../cnn_1/ConvLayer.vhd
vcom -93 -work work  ../PCA/PCA_64.vhd
vcom -93 -work work  ../Huffman_code/Huffman64.vhd
vcom -93 -work work  Entropy_encoding.vhd
vcom -93 -work work  Entropy_encoding_tb.vhd
vsim work.Entropy_encoding_tb
do wave.do
run 1000ns

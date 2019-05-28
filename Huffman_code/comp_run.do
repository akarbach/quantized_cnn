vcom -93 -work work  ../Fifo/Fifo.vhd
vcom -93 -work work  Huffman.vhd
vcom -93 -work work  Huffman_dec.vhd
vcom -93 -work work  Huffman64.vhd
vcom -93 -work work  Huffman_tb.vhd
vsim work.Huffman_tb
do wave.do
run 1000ns

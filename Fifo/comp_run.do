vcom -93 -work work  Fifo.vhd  Fifo_tb.vhd
vsim work.Fifo_tb
do wave.do
run 1000ns

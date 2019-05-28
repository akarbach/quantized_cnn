vcom -93 -work work  multROM.vhd
vcom -93 -work work  Binary_adder8.vhd
vcom -93 -work work  Binary_adder_tb.vhd
vsim work.Binary_adder_tb
do wave.do
run 1000ns

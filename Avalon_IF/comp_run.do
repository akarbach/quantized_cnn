vcom -93 -work work  Avalon_IF.vhd  Avalon_IF_tb.vhd
vsim work.Avalon_IF_tb
do wave.do
run 1000ns

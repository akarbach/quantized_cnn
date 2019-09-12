vcom -2008 -work work  Max3.vhd
vcom -2008 -work work  Pooling_calc.vhd
vcom -2008 -work work  Pooling_tb.vhd
vsim work.Pooling_tb
do wave.do
run 1000ns

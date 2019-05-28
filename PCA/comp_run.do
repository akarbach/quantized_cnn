vcom -93 -work work  custom_types.vhd
vcom -93 -work work  ../binary_adder/Binary_adder8.vhd
vcom -93 -work work  PCA_64.vhd
vcom -93 -work work  PCA_64_tb.vhd
vsim work.PCA_64_tb
do wave.do
run 10000ns

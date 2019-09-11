vcom -2008 -work work  ../cnn_1/ConvLayer_types_package.vhd
vcom -2008 -work work  PCA_pixel.vhd
vcom -2008 -work work  PCA_pixel_tb.vhd
vsim work.PCA_pixel_tb
do wave.do
run 1000ns

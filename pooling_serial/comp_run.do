vcom -2008 -work work  ../cnn_1/ConvLayer_types_package.vhd
vcom -2008 -work work  ../rest_integer_div/rest_integer_pip_v1/fulladd.vhd
vcom -2008 -work work  ../rest_integer_div/rest_integer_pip_v1/LPM_COMPONENTS.vhd
vcom -2008 -work work  ../rest_integer_div/rest_integer_pip_v1/LPM_COMMON_CONVERSION.vhd
vcom -2008 -work work  ../rest_integer_div/rest_integer_pip_v1/lpm_shiftreg.vhd
vcom -2008 -work work  ../rest_integer_div/rest_integer_pip_v1/dffe.vhd
vcom -2008 -work work  ../rest_integer_div/rest_integer_pip_v1/unit_proc.vhd
vcom -2008 -work work  ../rest_integer_div/rest_integer_pip_v1/res_div_pip.vhd

vcom -2008 -work work  Pooling_serial.vhd
vcom -2008 -work work  Pooling_serial_tb.vhd
vsim work.Pooling_serial_tb
do wave.do
run 10000ns

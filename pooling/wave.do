onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix decimal /convlayer_tb/DUT/clk
add wave -noupdate -radix decimal /convlayer_tb/DUT/d_in
add wave -noupdate -radix decimal /convlayer_tb/DUT/en_in
add wave -noupdate -radix decimal /convlayer_tb/DUT/CL_d_g/data2conv1
add wave -noupdate -radix decimal /convlayer_tb/DUT/CL_d_g/data2conv2
add wave -noupdate -radix decimal /convlayer_tb/DUT/CL_d_g/data2conv3
add wave -noupdate -radix decimal /convlayer_tb/DUT/CL_d_g/data2conv4
add wave -noupdate -radix decimal /convlayer_tb/DUT/CL_d_g/data2conv5
add wave -noupdate -radix decimal /convlayer_tb/DUT/CL_d_g/data2conv6
add wave -noupdate -radix decimal /convlayer_tb/DUT/CL_d_g/data2conv7
add wave -noupdate -radix decimal /convlayer_tb/DUT/CL_d_g/data2conv8
add wave -noupdate -radix decimal /convlayer_tb/DUT/CL_d_g/data2conv9
add wave -noupdate -radix decimal /convlayer_tb/DUT/CL_d_g/en_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {858518 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 129
configure wave -valuecolwidth 223
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {831341 ps} {1008877 ps}

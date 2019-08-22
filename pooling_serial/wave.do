onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /pooling_serial_tb/clk
add wave -noupdate -radix unsigned /pooling_serial_tb/d_in
add wave -noupdate -radix unsigned /pooling_serial_tb/en_in
add wave -noupdate -radix unsigned /pooling_serial_tb/sof_in
add wave -noupdate -radix unsigned /pooling_serial_tb/d_out
add wave -noupdate /pooling_serial_tb/DUT/en_shift
add wave -noupdate -radix unsigned /pooling_serial_tb/en_out
add wave -noupdate -radix unsigned /pooling_serial_tb/sof_out
add wave -noupdate -radix unsigned -childformat {{/pooling_serial_tb/DUT/d_ext(0) -radix unsigned} {/pooling_serial_tb/DUT/d_ext(1) -radix unsigned}} -subitemconfig {/pooling_serial_tb/DUT/d_ext(0) {-height 17 -radix unsigned} /pooling_serial_tb/DUT/d_ext(1) {-height 17 -radix unsigned}} /pooling_serial_tb/DUT/d_ext
add wave -noupdate -radix unsigned -childformat {{/pooling_serial_tb/DUT/acc(0) -radix unsigned} {/pooling_serial_tb/DUT/acc(1) -radix unsigned}} -subitemconfig {/pooling_serial_tb/DUT/acc(0) {-height 17 -radix unsigned} /pooling_serial_tb/DUT/acc(1) {-height 17 -radix unsigned}} /pooling_serial_tb/DUT/acc
add wave -noupdate -radix unsigned -childformat {{/pooling_serial_tb/DUT/acc1(0) -radix unsigned} {/pooling_serial_tb/DUT/acc1(1) -radix unsigned}} -subitemconfig {/pooling_serial_tb/DUT/acc1(0) {-height 17 -radix unsigned} /pooling_serial_tb/DUT/acc1(1) {-height 17 -radix unsigned}} /pooling_serial_tb/DUT/acc1
add wave -noupdate -radix unsigned /pooling_serial_tb/DUT/dividend
add wave -noupdate -radix unsigned /pooling_serial_tb/DUT/div_out
add wave -noupdate -radix unsigned /pooling_serial_tb/DUT/d_out
add wave -noupdate -radix unsigned /pooling_serial_tb/DUT/in_row
add wave -noupdate -radix unsigned /pooling_serial_tb/DUT/in_col
add wave -noupdate -radix unsigned /pooling_serial_tb/DUT/row_num
add wave -noupdate -radix unsigned /pooling_serial_tb/DUT/col_num
add wave -noupdate /pooling_serial_tb/clk
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {544885 ps} 0}
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
WaveRestoreZoom {469157 ps} {756581 ps}

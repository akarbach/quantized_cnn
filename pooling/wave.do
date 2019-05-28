onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix decimal /pooling_tb/DUT/rst
add wave -noupdate -radix decimal /pooling_tb/DUT/clk
add wave -noupdate -radix decimal /pooling_tb/DUT/N
add wave -noupdate -radix decimal /pooling_tb/DUT/P
add wave -noupdate -radix decimal /pooling_tb/DUT/d_in
add wave -noupdate -radix decimal /pooling_tb/DUT/en_in
add wave -noupdate -radix decimal /pooling_tb/DUT/sof_in
add wave -noupdate -radix decimal /pooling_tb/DUT/d_out
add wave -noupdate -radix decimal /pooling_tb/DUT/en_out
add wave -noupdate -radix decimal /pooling_tb/DUT/sof_out
add wave -noupdate -radix decimal /pooling_tb/DUT/max_old
add wave -noupdate -radix decimal /pooling_tb/DUT/max_new
add wave -noupdate -radix decimal /pooling_tb/DUT/max_2mem
add wave -noupdate -radix decimal /pooling_tb/DUT/write_new_max
add wave -noupdate -group {shift regs} -radix decimal /pooling_tb/DUT/d_in1
add wave -noupdate -group {shift regs} -radix decimal /pooling_tb/DUT/d_in2
add wave -noupdate -group {shift regs} -radix decimal /pooling_tb/DUT/d_in3
add wave -noupdate -group {shift regs} -radix decimal /pooling_tb/DUT/en_in1
add wave -noupdate -group {shift regs} -radix decimal /pooling_tb/DUT/en_in2
add wave -noupdate -group {shift regs} -radix decimal /pooling_tb/DUT/en_in3
add wave -noupdate -radix unsigned /pooling_tb/DUT/addr_rd
add wave -noupdate -radix unsigned /pooling_tb/DUT/addr_wr
add wave -noupdate -radix decimal -childformat {{/pooling_tb/DUT/mem_line1(0) -radix decimal} {/pooling_tb/DUT/mem_line1(1) -radix decimal} {/pooling_tb/DUT/mem_line1(2) -radix decimal} {/pooling_tb/DUT/mem_line1(3) -radix decimal} {/pooling_tb/DUT/mem_line1(4) -radix decimal}} -expand -subitemconfig {/pooling_tb/DUT/mem_line1(0) {-height 16 -radix decimal} /pooling_tb/DUT/mem_line1(1) {-height 16 -radix decimal} /pooling_tb/DUT/mem_line1(2) {-height 16 -radix decimal} /pooling_tb/DUT/mem_line1(3) {-height 16 -radix decimal} /pooling_tb/DUT/mem_line1(4) {-height 16 -radix decimal}} /pooling_tb/DUT/mem_line1
add wave -noupdate -radix decimal /pooling_tb/DUT/read_old_max
add wave -noupdate -radix unsigned /pooling_tb/DUT/row_num
add wave -noupdate -radix unsigned /pooling_tb/DUT/col_num
add wave -noupdate -radix unsigned /pooling_tb/DUT/p_index
add wave -noupdate -radix unsigned /pooling_tb/DUT/row_num_d
add wave -noupdate -radix unsigned /pooling_tb/DUT/col_num_d
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {140481 ps} 0}
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
WaveRestoreZoom {105676 ps} {283212 ps}

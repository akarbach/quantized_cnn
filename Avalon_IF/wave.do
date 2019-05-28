onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /huffman_tb/DUT/N
add wave -noupdate -radix unsigned /huffman_tb/DUT/M
add wave -noupdate -radix unsigned /huffman_tb/DUT/W
add wave -noupdate -radix unsigned /huffman_tb/DUT/clk
add wave -noupdate -radix unsigned /huffman_tb/DUT/init_en
add wave -noupdate -radix unsigned /huffman_tb/DUT/alpha_data
add wave -noupdate -radix unsigned /huffman_tb/DUT/alpha_code
add wave -noupdate -radix unsigned /huffman_tb/DUT/alpha_width
add wave -noupdate -radix unsigned /huffman_tb/DUT/Huf_code_m
add wave -noupdate -radix unsigned /huffman_tb/DUT/Huf_width_m
add wave -noupdate -radix unsigned /huffman_tb/DUT/d_in
add wave -noupdate -radix unsigned /huffman_tb/DUT/en_in
add wave -noupdate /huffman_tb/DUT/eof_in
add wave -noupdate -radix hexadecimal /huffman_tb/DUT/Huf_coded
add wave -noupdate -radix hexadecimal /huffman_tb/DUT/Huf_width
add wave -noupdate -radix unsigned /huffman_tb/DUT/pointer
add wave -noupdate -radix hexadecimal -childformat {{/huffman_tb/DUT/out_buff(23) -radix hexadecimal} {/huffman_tb/DUT/out_buff(22) -radix hexadecimal} {/huffman_tb/DUT/out_buff(21) -radix hexadecimal} {/huffman_tb/DUT/out_buff(20) -radix hexadecimal} {/huffman_tb/DUT/out_buff(19) -radix hexadecimal} {/huffman_tb/DUT/out_buff(18) -radix hexadecimal} {/huffman_tb/DUT/out_buff(17) -radix hexadecimal} {/huffman_tb/DUT/out_buff(16) -radix hexadecimal} {/huffman_tb/DUT/out_buff(15) -radix hexadecimal} {/huffman_tb/DUT/out_buff(14) -radix hexadecimal} {/huffman_tb/DUT/out_buff(13) -radix hexadecimal} {/huffman_tb/DUT/out_buff(12) -radix hexadecimal} {/huffman_tb/DUT/out_buff(11) -radix hexadecimal} {/huffman_tb/DUT/out_buff(10) -radix hexadecimal} {/huffman_tb/DUT/out_buff(9) -radix hexadecimal} {/huffman_tb/DUT/out_buff(8) -radix hexadecimal} {/huffman_tb/DUT/out_buff(7) -radix hexadecimal} {/huffman_tb/DUT/out_buff(6) -radix hexadecimal} {/huffman_tb/DUT/out_buff(5) -radix hexadecimal} {/huffman_tb/DUT/out_buff(4) -radix hexadecimal} {/huffman_tb/DUT/out_buff(3) -radix hexadecimal} {/huffman_tb/DUT/out_buff(2) -radix hexadecimal} {/huffman_tb/DUT/out_buff(1) -radix hexadecimal} {/huffman_tb/DUT/out_buff(0) -radix hexadecimal}} -subitemconfig {/huffman_tb/DUT/out_buff(23) {-height 16 -radix hexadecimal} /huffman_tb/DUT/out_buff(22) {-height 16 -radix hexadecimal} /huffman_tb/DUT/out_buff(21) {-height 16 -radix hexadecimal} /huffman_tb/DUT/out_buff(20) {-height 16 -radix hexadecimal} /huffman_tb/DUT/out_buff(19) {-height 16 -radix hexadecimal} /huffman_tb/DUT/out_buff(18) {-height 16 -radix hexadecimal} /huffman_tb/DUT/out_buff(17) {-height 16 -radix hexadecimal} /huffman_tb/DUT/out_buff(16) {-height 16 -radix hexadecimal} /huffman_tb/DUT/out_buff(15) {-height 16 -radix hexadecimal} /huffman_tb/DUT/out_buff(14) {-height 16 -radix hexadecimal} /huffman_tb/DUT/out_buff(13) {-height 16 -radix hexadecimal} /huffman_tb/DUT/out_buff(12) {-height 16 -radix hexadecimal} /huffman_tb/DUT/out_buff(11) {-height 16 -radix hexadecimal} /huffman_tb/DUT/out_buff(10) {-height 16 -radix hexadecimal} /huffman_tb/DUT/out_buff(9) {-height 16 -radix hexadecimal} /huffman_tb/DUT/out_buff(8) {-height 16 -radix hexadecimal} /huffman_tb/DUT/out_buff(7) {-height 16 -radix hexadecimal} /huffman_tb/DUT/out_buff(6) {-height 16 -radix hexadecimal} /huffman_tb/DUT/out_buff(5) {-height 16 -radix hexadecimal} /huffman_tb/DUT/out_buff(4) {-height 16 -radix hexadecimal} /huffman_tb/DUT/out_buff(3) {-height 16 -radix hexadecimal} /huffman_tb/DUT/out_buff(2) {-height 16 -radix hexadecimal} /huffman_tb/DUT/out_buff(1) {-height 16 -radix hexadecimal} /huffman_tb/DUT/out_buff(0) {-height 16 -radix hexadecimal}} /huffman_tb/DUT/out_buff
add wave -noupdate -radix unsigned /huffman_tb/DUT/Huf_en
add wave -noupdate -radix hexadecimal /huffman_tb/DUT/d_out
add wave -noupdate -radix hexadecimal /huffman_tb/DUT/en_out
add wave -noupdate /huffman_tb/DUT/eof_out
add wave -noupdate /huffman_tb/DUT/Huf_width_i
add wave -noupdate /huffman_tb/DUT/pointer_i
add wave -noupdate -radix decimal /huffman_tb/DUT/old_tail_M
add wave -noupdate -radix decimal /huffman_tb/DUT/new_val_L
add wave -noupdate -radix decimal /huffman_tb/DUT/new_val_M
add wave -noupdate /huffman_tb/DUT/Huf_eof
add wave -noupdate /huffman_tb/DUT/Huf_eof2
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {304670 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 129
configure wave -valuecolwidth 58
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
WaveRestoreZoom {205343 ps} {336593 ps}

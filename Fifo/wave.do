onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /fifo_tb/Clk
add wave -noupdate /fifo_tb/reset
add wave -noupdate /fifo_tb/enr
add wave -noupdate /fifo_tb/enw
add wave -noupdate /fifo_tb/uut/burst
add wave -noupdate /fifo_tb/empty
add wave -noupdate /fifo_tb/burst_r
add wave -noupdate /fifo_tb/full
add wave -noupdate -radix hexadecimal /fifo_tb/data_in
add wave -noupdate -radix hexadecimal /fifo_tb/data_out
add wave -noupdate /fifo_tb/i
add wave -noupdate /fifo_tb/Clk_period
add wave -noupdate /fifo_tb/depth
add wave -noupdate -radix hexadecimal /fifo_tb/uut/data2fifo
add wave -noupdate -radix hexadecimal /fifo_tb/uut/enw2fifo
add wave -noupdate -radix hexadecimal /fifo_tb/uut/count2fifo
add wave -noupdate -radix hexadecimal /fifo_tb/uut/WidthMult
add wave -noupdate -radix hexadecimal /fifo_tb/uut/memory
add wave -noupdate -radix decimal /fifo_tb/uut/dbg_num_elem
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {793657 ps} 0}
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
WaveRestoreZoom {772896 ps} {1011953 ps}

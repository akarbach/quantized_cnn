onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix decimal /binary_adder_tb/DUT/en_in
add wave -noupdate -radix decimal /binary_adder_tb/DUT/Multiplier
add wave -noupdate -radix decimal /binary_adder_tb/DUT/Multiplicand
add wave -noupdate -radix decimal -childformat {{/binary_adder_tb/DUT/d_out(15) -radix decimal} {/binary_adder_tb/DUT/d_out(14) -radix decimal} {/binary_adder_tb/DUT/d_out(13) -radix decimal} {/binary_adder_tb/DUT/d_out(12) -radix decimal} {/binary_adder_tb/DUT/d_out(11) -radix decimal} {/binary_adder_tb/DUT/d_out(10) -radix decimal} {/binary_adder_tb/DUT/d_out(9) -radix decimal} {/binary_adder_tb/DUT/d_out(8) -radix decimal} {/binary_adder_tb/DUT/d_out(7) -radix decimal} {/binary_adder_tb/DUT/d_out(6) -radix decimal} {/binary_adder_tb/DUT/d_out(5) -radix decimal} {/binary_adder_tb/DUT/d_out(4) -radix decimal} {/binary_adder_tb/DUT/d_out(3) -radix decimal} {/binary_adder_tb/DUT/d_out(2) -radix decimal} {/binary_adder_tb/DUT/d_out(1) -radix decimal} {/binary_adder_tb/DUT/d_out(0) -radix decimal}} -subitemconfig {/binary_adder_tb/DUT/d_out(15) {-height 16 -radix decimal} /binary_adder_tb/DUT/d_out(14) {-height 16 -radix decimal} /binary_adder_tb/DUT/d_out(13) {-height 16 -radix decimal} /binary_adder_tb/DUT/d_out(12) {-height 16 -radix decimal} /binary_adder_tb/DUT/d_out(11) {-height 16 -radix decimal} /binary_adder_tb/DUT/d_out(10) {-height 16 -radix decimal} /binary_adder_tb/DUT/d_out(9) {-height 16 -radix decimal} /binary_adder_tb/DUT/d_out(8) {-height 16 -radix decimal} /binary_adder_tb/DUT/d_out(7) {-height 16 -radix decimal} /binary_adder_tb/DUT/d_out(6) {-height 16 -radix decimal} /binary_adder_tb/DUT/d_out(5) {-height 16 -radix decimal} /binary_adder_tb/DUT/d_out(4) {-height 16 -radix decimal} /binary_adder_tb/DUT/d_out(3) {-height 16 -radix decimal} /binary_adder_tb/DUT/d_out(2) {-height 16 -radix decimal} /binary_adder_tb/DUT/d_out(1) {-height 16 -radix decimal} /binary_adder_tb/DUT/d_out(0) {-height 16 -radix decimal}} /binary_adder_tb/DUT/d_out
add wave -noupdate -radix decimal /binary_adder_tb/DUT/en_out
add wave -noupdate -radix decimal /binary_adder_tb/DUT/Multiplier
add wave -noupdate -radix decimal /binary_adder_tb/DUT/Multiplicand
add wave -noupdate -radix decimal /binary_adder_tb/DUT/MultiplicandS
add wave -noupdate -radix decimal /binary_adder_tb/DUT/MultiplicandM
add wave -noupdate -radix decimal /binary_adder_tb/DUT/MultiplierD
add wave -noupdate -radix decimal /binary_adder_tb/DUT/MultiplierAnd0
add wave -noupdate -radix decimal /binary_adder_tb/DUT/MultiplierAnd1
add wave -noupdate -radix decimal /binary_adder_tb/DUT/MultiplierAnd2
add wave -noupdate -radix decimal /binary_adder_tb/DUT/MultiplierAnd3
add wave -noupdate -radix decimal /binary_adder_tb/DUT/MultiplierAnd4
add wave -noupdate -radix decimal /binary_adder_tb/DUT/MultiplierAnd5
add wave -noupdate -radix decimal /binary_adder_tb/DUT/MultiplierAnd6
add wave -noupdate -radix decimal /binary_adder_tb/DUT/MultiplierAnd7
add wave -noupdate -radix decimal /binary_adder_tb/DUT/MultiplierAnd01
add wave -noupdate -radix decimal /binary_adder_tb/DUT/MultiplierAnd23
add wave -noupdate -radix decimal /binary_adder_tb/DUT/MultiplierAnd45
add wave -noupdate -radix decimal /binary_adder_tb/DUT/MultiplierAnd67
add wave -noupdate -radix decimal /binary_adder_tb/DUT/MultiplierAnd03
add wave -noupdate -radix decimal /binary_adder_tb/DUT/MultiplierAnd47
add wave -noupdate -radix decimal /binary_adder_tb/DUT/MultiplierAnd07
add wave -noupdate -radix decimal /binary_adder_tb/DUT/MultiplicandS
add wave -noupdate -radix decimal /binary_adder_tb/DUT/MultiplicandS2
add wave -noupdate -radix decimal /binary_adder_tb/DUT/MultiplicandS3
add wave -noupdate -radix decimal /binary_adder_tb/DUT/MultiplicandS4
add wave -noupdate -radix decimal /binary_adder_tb/DUT/MultiplicandS5
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6621 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 166
configure wave -valuecolwidth 110
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
WaveRestoreZoom {0 ps} {88450 ps}

onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix decimal /pca_pixel_tb/dut/data_in
add wave -noupdate -radix decimal /pca_pixel_tb/dut/data_in_valid
add wave -noupdate -radix decimal -childformat {{/pca_pixel_tb/dut/weight_in(0) -radix decimal} {/pca_pixel_tb/dut/weight_in(1) -radix decimal} {/pca_pixel_tb/dut/weight_in(2) -radix decimal} {/pca_pixel_tb/dut/weight_in(3) -radix decimal}} -expand -subitemconfig {/pca_pixel_tb/dut/weight_in(0) {-height 17 -radix decimal} /pca_pixel_tb/dut/weight_in(1) {-height 17 -radix decimal} /pca_pixel_tb/dut/weight_in(2) {-height 17 -radix decimal} /pca_pixel_tb/dut/weight_in(3) {-height 17 -radix decimal}} /pca_pixel_tb/dut/weight_in
add wave -noupdate -radix hexadecimal -childformat {{/pca_pixel_tb/dut/partial_sums(0) -radix hexadecimal} {/pca_pixel_tb/dut/partial_sums(1) -radix hexadecimal} {/pca_pixel_tb/dut/partial_sums(2) -radix hexadecimal} {/pca_pixel_tb/dut/partial_sums(3) -radix hexadecimal} {/pca_pixel_tb/dut/partial_sums(4) -radix hexadecimal} {/pca_pixel_tb/dut/partial_sums(5) -radix hexadecimal}} -expand -subitemconfig {/pca_pixel_tb/dut/partial_sums(0) {-height 17 -radix hexadecimal} /pca_pixel_tb/dut/partial_sums(1) {-height 17 -radix hexadecimal} /pca_pixel_tb/dut/partial_sums(2) {-height 17 -radix hexadecimal} /pca_pixel_tb/dut/partial_sums(3) {-height 17 -radix hexadecimal} /pca_pixel_tb/dut/partial_sums(4) {-height 17 -radix hexadecimal} /pca_pixel_tb/dut/partial_sums(5) {-height 17 -radix hexadecimal}} /pca_pixel_tb/dut/partial_sums
add wave -noupdate -radix decimal /pca_pixel_tb/dut/index
add wave -noupdate /pca_pixel_tb/dut/init
add wave -noupdate -radix hexadecimal -childformat {{/pca_pixel_tb/dut/mem_sums(0) -radix hexadecimal} {/pca_pixel_tb/dut/mem_sums(1) -radix hexadecimal} {/pca_pixel_tb/dut/mem_sums(2) -radix hexadecimal} {/pca_pixel_tb/dut/mem_sums(3) -radix hexadecimal} {/pca_pixel_tb/dut/mem_sums(4) -radix hexadecimal} {/pca_pixel_tb/dut/mem_sums(5) -radix hexadecimal}} -expand -subitemconfig {/pca_pixel_tb/dut/mem_sums(0) {-radix hexadecimal} /pca_pixel_tb/dut/mem_sums(1) {-radix hexadecimal} /pca_pixel_tb/dut/mem_sums(2) {-radix hexadecimal} /pca_pixel_tb/dut/mem_sums(3) {-radix hexadecimal} /pca_pixel_tb/dut/mem_sums(4) {-radix hexadecimal} /pca_pixel_tb/dut/mem_sums(5) {-radix hexadecimal}} /pca_pixel_tb/dut/mem_sums
add wave -noupdate -radix hexadecimal /pca_pixel_tb/dut/mem_data_wr
add wave -noupdate -radix hexadecimal /pca_pixel_tb/dut/mem_data_rd
add wave -noupdate -radix decimal /pca_pixel_tb/dut/data_out
add wave -noupdate -radix decimal /pca_pixel_tb/dut/data_out_valid
add wave -noupdate -radix hexadecimal -childformat {{/pca_pixel_tb/dut/temp_mult0(15) -radix decimal} {/pca_pixel_tb/dut/temp_mult0(14) -radix decimal} {/pca_pixel_tb/dut/temp_mult0(13) -radix decimal} {/pca_pixel_tb/dut/temp_mult0(12) -radix decimal} {/pca_pixel_tb/dut/temp_mult0(11) -radix decimal} {/pca_pixel_tb/dut/temp_mult0(10) -radix decimal} {/pca_pixel_tb/dut/temp_mult0(9) -radix decimal} {/pca_pixel_tb/dut/temp_mult0(8) -radix decimal} {/pca_pixel_tb/dut/temp_mult0(7) -radix decimal} {/pca_pixel_tb/dut/temp_mult0(6) -radix decimal} {/pca_pixel_tb/dut/temp_mult0(5) -radix decimal} {/pca_pixel_tb/dut/temp_mult0(4) -radix decimal} {/pca_pixel_tb/dut/temp_mult0(3) -radix decimal} {/pca_pixel_tb/dut/temp_mult0(2) -radix decimal} {/pca_pixel_tb/dut/temp_mult0(1) -radix decimal} {/pca_pixel_tb/dut/temp_mult0(0) -radix decimal}} -subitemconfig {/pca_pixel_tb/dut/temp_mult0(15) {-height 17 -radix decimal} /pca_pixel_tb/dut/temp_mult0(14) {-height 17 -radix decimal} /pca_pixel_tb/dut/temp_mult0(13) {-height 17 -radix decimal} /pca_pixel_tb/dut/temp_mult0(12) {-height 17 -radix decimal} /pca_pixel_tb/dut/temp_mult0(11) {-height 17 -radix decimal} /pca_pixel_tb/dut/temp_mult0(10) {-height 17 -radix decimal} /pca_pixel_tb/dut/temp_mult0(9) {-height 17 -radix decimal} /pca_pixel_tb/dut/temp_mult0(8) {-height 17 -radix decimal} /pca_pixel_tb/dut/temp_mult0(7) {-height 17 -radix decimal} /pca_pixel_tb/dut/temp_mult0(6) {-height 17 -radix decimal} /pca_pixel_tb/dut/temp_mult0(5) {-height 17 -radix decimal} /pca_pixel_tb/dut/temp_mult0(4) {-height 17 -radix decimal} /pca_pixel_tb/dut/temp_mult0(3) {-height 17 -radix decimal} /pca_pixel_tb/dut/temp_mult0(2) {-height 17 -radix decimal} /pca_pixel_tb/dut/temp_mult0(1) {-height 17 -radix decimal} /pca_pixel_tb/dut/temp_mult0(0) {-height 17 -radix decimal}} /pca_pixel_tb/dut/temp_mult0
add wave -noupdate -radix hexadecimal /pca_pixel_tb/dut/temp_mult1
add wave -noupdate -radix hexadecimal /pca_pixel_tb/dut/temp_mult2
add wave -noupdate -radix hexadecimal /pca_pixel_tb/dut/temp_mult3
add wave -noupdate -radix decimal -childformat {{/pca_pixel_tb/dut/temp_mult0(15) -radix decimal} {/pca_pixel_tb/dut/temp_mult0(14) -radix decimal} {/pca_pixel_tb/dut/temp_mult0(13) -radix decimal} {/pca_pixel_tb/dut/temp_mult0(12) -radix decimal} {/pca_pixel_tb/dut/temp_mult0(11) -radix decimal} {/pca_pixel_tb/dut/temp_mult0(10) -radix decimal} {/pca_pixel_tb/dut/temp_mult0(9) -radix decimal} {/pca_pixel_tb/dut/temp_mult0(8) -radix decimal} {/pca_pixel_tb/dut/temp_mult0(7) -radix decimal} {/pca_pixel_tb/dut/temp_mult0(6) -radix decimal} {/pca_pixel_tb/dut/temp_mult0(5) -radix decimal} {/pca_pixel_tb/dut/temp_mult0(4) -radix decimal} {/pca_pixel_tb/dut/temp_mult0(3) -radix decimal} {/pca_pixel_tb/dut/temp_mult0(2) -radix decimal} {/pca_pixel_tb/dut/temp_mult0(1) -radix decimal} {/pca_pixel_tb/dut/temp_mult0(0) -radix decimal}} -subitemconfig {/pca_pixel_tb/dut/temp_mult0(15) {-height 17 -radix decimal} /pca_pixel_tb/dut/temp_mult0(14) {-height 17 -radix decimal} /pca_pixel_tb/dut/temp_mult0(13) {-height 17 -radix decimal} /pca_pixel_tb/dut/temp_mult0(12) {-height 17 -radix decimal} /pca_pixel_tb/dut/temp_mult0(11) {-height 17 -radix decimal} /pca_pixel_tb/dut/temp_mult0(10) {-height 17 -radix decimal} /pca_pixel_tb/dut/temp_mult0(9) {-height 17 -radix decimal} /pca_pixel_tb/dut/temp_mult0(8) {-height 17 -radix decimal} /pca_pixel_tb/dut/temp_mult0(7) {-height 17 -radix decimal} /pca_pixel_tb/dut/temp_mult0(6) {-height 17 -radix decimal} /pca_pixel_tb/dut/temp_mult0(5) {-height 17 -radix decimal} /pca_pixel_tb/dut/temp_mult0(4) {-height 17 -radix decimal} /pca_pixel_tb/dut/temp_mult0(3) {-height 17 -radix decimal} /pca_pixel_tb/dut/temp_mult0(2) {-height 17 -radix decimal} /pca_pixel_tb/dut/temp_mult0(1) {-height 17 -radix decimal} /pca_pixel_tb/dut/temp_mult0(0) {-height 17 -radix decimal}} /pca_pixel_tb/dut/temp_mult0
add wave -noupdate -radix decimal /pca_pixel_tb/dut/temp_mult1
add wave -noupdate -radix decimal /pca_pixel_tb/dut/temp_mult2
add wave -noupdate -radix decimal /pca_pixel_tb/dut/temp_mult3
add wave -noupdate /pca_pixel_tb/rst
add wave -noupdate /pca_pixel_tb/clk
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {74940 ps} 0}
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
WaveRestoreZoom {0 ps} {285925 ps}

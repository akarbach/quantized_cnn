onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /linear_serial_tb/dut/rst
add wave -noupdate -radix hexadecimal /linear_serial_tb/dut/w_in
add wave -noupdate -radix hexadecimal /linear_serial_tb/dut/w_en
add wave -noupdate -radix hexadecimal /linear_serial_tb/dut/w_pixel_N
add wave -noupdate -radix hexadecimal /linear_serial_tb/dut/w_pixel_L
add wave -noupdate -radix hexadecimal /linear_serial_tb/dut/w_num
add wave -noupdate -radix hexadecimal /linear_serial_tb/dut/w_lin_rdy
add wave -noupdate -radix hexadecimal /linear_serial_tb/dut/weight_lin
add wave -noupdate -radix unsigned /linear_serial_tb/dut/addr_wr
add wave -noupdate -radix hexadecimal -childformat {{/linear_serial_tb/dut/weight_mat(0) -radix hexadecimal} {/linear_serial_tb/dut/weight_mat(1) -radix hexadecimal} {/linear_serial_tb/dut/weight_mat(2) -radix hexadecimal} {/linear_serial_tb/dut/weight_mat(3) -radix hexadecimal} {/linear_serial_tb/dut/weight_mat(4) -radix hexadecimal} {/linear_serial_tb/dut/weight_mat(5) -radix hexadecimal} {/linear_serial_tb/dut/weight_mat(6) -radix hexadecimal} {/linear_serial_tb/dut/weight_mat(7) -radix hexadecimal} {/linear_serial_tb/dut/weight_mat(8) -radix hexadecimal} {/linear_serial_tb/dut/weight_mat(9) -radix hexadecimal} {/linear_serial_tb/dut/weight_mat(10) -radix hexadecimal} {/linear_serial_tb/dut/weight_mat(11) -radix hexadecimal}} -expand -subitemconfig {/linear_serial_tb/dut/weight_mat(0) {-height 17 -radix hexadecimal} /linear_serial_tb/dut/weight_mat(1) {-height 17 -radix hexadecimal} /linear_serial_tb/dut/weight_mat(2) {-height 17 -radix hexadecimal} /linear_serial_tb/dut/weight_mat(3) {-height 17 -radix hexadecimal} /linear_serial_tb/dut/weight_mat(4) {-height 17 -radix hexadecimal} /linear_serial_tb/dut/weight_mat(5) {-height 17 -radix hexadecimal} /linear_serial_tb/dut/weight_mat(6) {-height 17 -radix hexadecimal} /linear_serial_tb/dut/weight_mat(7) {-height 17 -radix hexadecimal} /linear_serial_tb/dut/weight_mat(8) {-height 17 -radix hexadecimal} /linear_serial_tb/dut/weight_mat(9) {-height 17 -radix hexadecimal} /linear_serial_tb/dut/weight_mat(10) {-height 17 -radix hexadecimal} /linear_serial_tb/dut/weight_mat(11) {-height 17 -radix hexadecimal}} /linear_serial_tb/dut/weight_mat
add wave -noupdate -radix decimal -childformat {{/linear_serial_tb/d_in(0) -radix decimal} {/linear_serial_tb/d_in(1) -radix decimal} {/linear_serial_tb/d_in(2) -radix decimal} {/linear_serial_tb/d_in(3) -radix decimal}} -expand -subitemconfig {/linear_serial_tb/d_in(0) {-height 17 -radix decimal} /linear_serial_tb/d_in(1) {-height 17 -radix decimal} /linear_serial_tb/d_in(2) {-height 17 -radix decimal} /linear_serial_tb/d_in(3) {-height 17 -radix decimal}} /linear_serial_tb/d_in
add wave -noupdate -radix decimal /linear_serial_tb/en_in
add wave -noupdate -radix decimal /linear_serial_tb/dut/pixel_N
add wave -noupdate -radix decimal /linear_serial_tb/dut/pixel_L
add wave -noupdate -radix unsigned /linear_serial_tb/dut/pixel_L_d
add wave -noupdate -radix decimal /linear_serial_tb/dut/mult_proc
add wave -noupdate -radix decimal /linear_serial_tb/dut/new_acc
add wave -noupdate /linear_serial_tb/dut/weight_mat_line1
add wave -noupdate /linear_serial_tb/dut/weight_mat_line2
add wave -noupdate -radix unsigned /linear_serial_tb/dut/weight_mat_line
add wave -noupdate -radix decimal -childformat {{/linear_serial_tb/dut/mult_res(0) -radix decimal} {/linear_serial_tb/dut/mult_res(1) -radix decimal}} -expand -subitemconfig {/linear_serial_tb/dut/mult_res(0) {-height 17 -radix decimal} /linear_serial_tb/dut/mult_res(1) {-height 17 -radix decimal}} /linear_serial_tb/dut/mult_res
add wave -noupdate /linear_serial_tb/dut/acc_min
add wave -noupdate /linear_serial_tb/dut/acc_max
add wave -noupdate -radix decimal -childformat {{/linear_serial_tb/dut/acc(0) -radix decimal} {/linear_serial_tb/dut/acc(1) -radix decimal} {/linear_serial_tb/dut/acc(2) -radix decimal} {/linear_serial_tb/dut/acc(3) -radix decimal} {/linear_serial_tb/dut/acc(4) -radix decimal} {/linear_serial_tb/dut/acc(5) -radix decimal}} -expand -subitemconfig {/linear_serial_tb/dut/acc(0) {-height 17 -radix decimal} /linear_serial_tb/dut/acc(1) {-height 17 -radix decimal} /linear_serial_tb/dut/acc(2) {-height 17 -radix decimal} /linear_serial_tb/dut/acc(3) {-height 17 -radix decimal} /linear_serial_tb/dut/acc(4) {-height 17 -radix decimal} /linear_serial_tb/dut/acc(5) {-height 17 -radix decimal}} /linear_serial_tb/dut/acc
add wave -noupdate -radix decimal -childformat {{/linear_serial_tb/d_out(0) -radix decimal} {/linear_serial_tb/d_out(1) -radix decimal} {/linear_serial_tb/d_out(2) -radix decimal} {/linear_serial_tb/d_out(3) -radix decimal} {/linear_serial_tb/d_out(4) -radix decimal} {/linear_serial_tb/d_out(5) -radix decimal}} -expand -subitemconfig {/linear_serial_tb/d_out(0) {-height 17 -radix decimal} /linear_serial_tb/d_out(1) {-height 17 -radix decimal} /linear_serial_tb/d_out(2) {-height 17 -radix decimal} /linear_serial_tb/d_out(3) {-height 17 -radix decimal} /linear_serial_tb/d_out(4) {-height 17 -radix decimal} /linear_serial_tb/d_out(5) {-height 17 -radix decimal}} /linear_serial_tb/d_out
add wave -noupdate -radix decimal /linear_serial_tb/dut/negative_val
add wave -noupdate /linear_serial_tb/dut/N
add wave -noupdate /linear_serial_tb/dut/SR
add wave -noupdate -radix unsigned /linear_serial_tb/dut/sign_chek1
add wave -noupdate -radix unsigned /linear_serial_tb/dut/sign_chek3
add wave -noupdate -radix unsigned /linear_serial_tb/dut/sign_chek5
add wave -noupdate -radix decimal /linear_serial_tb/en_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {737547 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 159
configure wave -valuecolwidth 266
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
WaveRestoreZoom {695763 ps} {1016013 ps}

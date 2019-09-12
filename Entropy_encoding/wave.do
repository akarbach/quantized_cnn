onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group Input -radix hexadecimal /entropy_encoding_tb/d_in
add wave -noupdate -expand -group Input -radix hexadecimal /entropy_encoding_tb/en_in
add wave -noupdate -expand -group Input -radix hexadecimal /entropy_encoding_tb/sof_in
add wave -noupdate -expand -group PCAs -radix hexadecimal /entropy_encoding_tb/DUT/pca_en_out
add wave -noupdate -expand -group PCAs -radix hexadecimal /entropy_encoding_tb/DUT/pca_sof_out
add wave -noupdate /entropy_encoding_tb/DUT/PCA_en
add wave -noupdate /entropy_encoding_tb/DUT/cl_en_out
add wave -noupdate /entropy_encoding_tb/DUT/pca_en_out
add wave -noupdate -radix hexadecimal /entropy_encoding_tb/DUT/d01_out1
add wave -noupdate -radix hexadecimal -childformat {{/entropy_encoding_tb/DUT/d01_out(19) -radix hexadecimal} {/entropy_encoding_tb/DUT/d01_out(18) -radix hexadecimal} {/entropy_encoding_tb/DUT/d01_out(17) -radix hexadecimal} {/entropy_encoding_tb/DUT/d01_out(16) -radix hexadecimal} {/entropy_encoding_tb/DUT/d01_out(15) -radix hexadecimal} {/entropy_encoding_tb/DUT/d01_out(14) -radix hexadecimal} {/entropy_encoding_tb/DUT/d01_out(13) -radix hexadecimal} {/entropy_encoding_tb/DUT/d01_out(12) -radix hexadecimal} {/entropy_encoding_tb/DUT/d01_out(11) -radix hexadecimal} {/entropy_encoding_tb/DUT/d01_out(10) -radix hexadecimal} {/entropy_encoding_tb/DUT/d01_out(9) -radix hexadecimal} {/entropy_encoding_tb/DUT/d01_out(8) -radix hexadecimal} {/entropy_encoding_tb/DUT/d01_out(7) -radix hexadecimal} {/entropy_encoding_tb/DUT/d01_out(6) -radix hexadecimal} {/entropy_encoding_tb/DUT/d01_out(5) -radix hexadecimal} {/entropy_encoding_tb/DUT/d01_out(4) -radix hexadecimal} {/entropy_encoding_tb/DUT/d01_out(3) -radix hexadecimal} {/entropy_encoding_tb/DUT/d01_out(2) -radix hexadecimal} {/entropy_encoding_tb/DUT/d01_out(1) -radix hexadecimal} {/entropy_encoding_tb/DUT/d01_out(0) -radix hexadecimal}} -subitemconfig {/entropy_encoding_tb/DUT/d01_out(19) {-height 17 -radix hexadecimal} /entropy_encoding_tb/DUT/d01_out(18) {-height 17 -radix hexadecimal} /entropy_encoding_tb/DUT/d01_out(17) {-height 17 -radix hexadecimal} /entropy_encoding_tb/DUT/d01_out(16) {-height 17 -radix hexadecimal} /entropy_encoding_tb/DUT/d01_out(15) {-height 17 -radix hexadecimal} /entropy_encoding_tb/DUT/d01_out(14) {-height 17 -radix hexadecimal} /entropy_encoding_tb/DUT/d01_out(13) {-height 17 -radix hexadecimal} /entropy_encoding_tb/DUT/d01_out(12) {-height 17 -radix hexadecimal} /entropy_encoding_tb/DUT/d01_out(11) {-height 17 -radix hexadecimal} /entropy_encoding_tb/DUT/d01_out(10) {-height 17 -radix hexadecimal} /entropy_encoding_tb/DUT/d01_out(9) {-height 17 -radix hexadecimal} /entropy_encoding_tb/DUT/d01_out(8) {-height 17 -radix hexadecimal} /entropy_encoding_tb/DUT/d01_out(7) {-height 17 -radix hexadecimal} /entropy_encoding_tb/DUT/d01_out(6) {-height 17 -radix hexadecimal} /entropy_encoding_tb/DUT/d01_out(5) {-height 17 -radix hexadecimal} /entropy_encoding_tb/DUT/d01_out(4) {-height 17 -radix hexadecimal} /entropy_encoding_tb/DUT/d01_out(3) {-height 17 -radix hexadecimal} /entropy_encoding_tb/DUT/d01_out(2) {-height 17 -radix hexadecimal} /entropy_encoding_tb/DUT/d01_out(1) {-height 17 -radix hexadecimal} /entropy_encoding_tb/DUT/d01_out(0) {-height 17 -radix hexadecimal}} /entropy_encoding_tb/DUT/d01_out
add wave -noupdate /entropy_encoding_tb/DUT/Huff_enc_en
add wave -noupdate /entropy_encoding_tb/pca_w_en
add wave -noupdate /entropy_encoding_tb/pca_w_num
add wave -noupdate /entropy_encoding_tb/pca_w_in
add wave -noupdate /entropy_encoding_tb/DUT/w_en
add wave -noupdate /entropy_encoding_tb/DUT/w_lin_rdy
add wave -noupdate /entropy_encoding_tb/DUT/w_inputN
add wave -noupdate /entropy_encoding_tb/DUT/w_inputN_i
add wave -noupdate /entropy_encoding_tb/DUT/weight_lin
add wave -noupdate -radix unsigned /entropy_encoding_tb/DUT/w_CLin_n
add wave -noupdate /entropy_encoding_tb/DUT/w_CLout_n
add wave -noupdate -radix hexadecimal -childformat {{/entropy_encoding_tb/DUT/w_vec1(0) -radix hexadecimal} {/entropy_encoding_tb/DUT/w_vec1(1) -radix hexadecimal} {/entropy_encoding_tb/DUT/w_vec1(2) -radix hexadecimal} {/entropy_encoding_tb/DUT/w_vec1(3) -radix hexadecimal} {/entropy_encoding_tb/DUT/w_vec1(4) -radix hexadecimal} {/entropy_encoding_tb/DUT/w_vec1(5) -radix hexadecimal}} -expand -subitemconfig {/entropy_encoding_tb/DUT/w_vec1(0) {-height 17 -radix hexadecimal} /entropy_encoding_tb/DUT/w_vec1(1) {-height 17 -radix hexadecimal} /entropy_encoding_tb/DUT/w_vec1(2) {-height 17 -radix hexadecimal} /entropy_encoding_tb/DUT/w_vec1(3) {-height 17 -radix hexadecimal} /entropy_encoding_tb/DUT/w_vec1(4) {-height 17 -radix hexadecimal} /entropy_encoding_tb/DUT/w_vec1(5) {-height 17 -radix hexadecimal}} /entropy_encoding_tb/DUT/w_vec1
add wave -noupdate -radix hexadecimal /entropy_encoding_tb/DUT/w_vec
add wave -noupdate -radix hexadecimal /entropy_encoding_tb/DUT/CL/data2conv1
add wave -noupdate -radix hexadecimal /entropy_encoding_tb/DUT/CL/data2conv2
add wave -noupdate -radix hexadecimal /entropy_encoding_tb/DUT/CL/data2conv3
add wave -noupdate -radix hexadecimal /entropy_encoding_tb/DUT/CL/data2conv4
add wave -noupdate -radix hexadecimal /entropy_encoding_tb/DUT/CL/w_vec
add wave -noupdate -radix hexadecimal /entropy_encoding_tb/DUT/CL/d_out1
add wave -noupdate /entropy_encoding_tb/DUT/CL/CL_inputs
add wave -noupdate /entropy_encoding_tb/DUT/CL/CL_outs
add wave -noupdate -radix hexadecimal /entropy_encoding_tb/DUT/CL/gen_inCL(0)/gen_CL(0)/CL_c/w1
add wave -noupdate -radix hexadecimal /entropy_encoding_tb/DUT/CL/gen_inCL(0)/gen_CL(0)/CL_c/w2
add wave -noupdate -radix hexadecimal /entropy_encoding_tb/DUT/CL/gen_inCL(0)/gen_CL(0)/CL_c/w3
add wave -noupdate -radix hexadecimal /entropy_encoding_tb/DUT/CL/gen_inCL(0)/gen_CL(0)/CL_c/w4
add wave -noupdate -radix hexadecimal /entropy_encoding_tb/DUT/CL/gen_inCL(0)/gen_CL(0)/CL_c/data2conv1
add wave -noupdate -radix hexadecimal /entropy_encoding_tb/DUT/CL/gen_inCL(0)/gen_CL(0)/CL_c/data2conv2
add wave -noupdate -radix hexadecimal /entropy_encoding_tb/DUT/CL/gen_inCL(0)/gen_CL(0)/CL_c/data2conv3
add wave -noupdate -radix decimal /entropy_encoding_tb/DUT/CL/gen_inCL(0)/gen_CL(0)/CL_c/data2conv4
add wave -noupdate -radix decimal /entropy_encoding_tb/DUT/CL/gen_inCL(0)/gen_CL(0)/CL_c/d_out
add wave -noupdate -radix decimal /entropy_encoding_tb/DUT/CL/gen_inCL(0)/gen_CL(0)/CL_c/en_out
add wave -noupdate -radix decimal /entropy_encoding_tb/DUT/CL/adder/d_4
add wave -noupdate -radix decimal /entropy_encoding_tb/DUT/CL/adder/d_sum
add wave -noupdate -radix decimal /entropy_encoding_tb/DUT/CL/adder/d_relu
add wave -noupdate -radix decimal /entropy_encoding_tb/DUT/CL/adder/d_ovf
add wave -noupdate -radix hexadecimal /entropy_encoding_tb/DUT/CL/d_sums
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {895000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 389
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
WaveRestoreZoom {0 ps} {1065750 ps}

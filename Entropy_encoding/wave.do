onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group Input -radix hexadecimal /entropy_encoding_tb/d_in
add wave -noupdate -expand -group Input -radix hexadecimal /entropy_encoding_tb/en_in
add wave -noupdate -expand -group Input -radix hexadecimal /entropy_encoding_tb/sof_in
add wave -noupdate -expand -group CL_01 /entropy_encoding_tb/DUT/CL01/en_in
add wave -noupdate -expand -group CL_01 -radix hexadecimal /entropy_encoding_tb/DUT/CL01/d_in
add wave -noupdate -expand -group CL_01 -radix hexadecimal /entropy_encoding_tb/DUT/CL01/Head
add wave -noupdate -expand -group CL_01 -radix hexadecimal /entropy_encoding_tb/DUT/CL01/Tail
add wave -noupdate -expand -group CL_01 -radix hexadecimal /entropy_encoding_tb/DUT/CL01/mem_line1
add wave -noupdate -expand -group CL_01 -radix hexadecimal /entropy_encoding_tb/DUT/CL01/d_mid1
add wave -noupdate -expand -group CL_01 -radix hexadecimal /entropy_encoding_tb/DUT/CL01/d_mid2
add wave -noupdate -expand -group CL_01 -radix hexadecimal /entropy_encoding_tb/DUT/CL01/d_mid3
add wave -noupdate -expand -group CL_01 -radix hexadecimal /entropy_encoding_tb/DUT/CL01/data2conv1
add wave -noupdate -expand -group CL_01 -radix hexadecimal /entropy_encoding_tb/DUT/CL01/data2conv2
add wave -noupdate -expand -group CL_01 -radix hexadecimal /entropy_encoding_tb/DUT/CL01/data2conv3
add wave -noupdate -expand -group CL_01 -radix hexadecimal /entropy_encoding_tb/DUT/CL01/data2conv4
add wave -noupdate -expand -group CL_01 -radix hexadecimal /entropy_encoding_tb/DUT/CL01/data2conv5
add wave -noupdate -expand -group CL_01 -radix hexadecimal /entropy_encoding_tb/DUT/CL01/data2conv6
add wave -noupdate -expand -group CL_01 -radix hexadecimal /entropy_encoding_tb/DUT/CL01/data2conv7
add wave -noupdate -expand -group CL_01 -radix hexadecimal /entropy_encoding_tb/DUT/CL01/data2conv8
add wave -noupdate -expand -group CL_01 -radix hexadecimal /entropy_encoding_tb/DUT/CL01/data2conv9
add wave -noupdate -expand -group CL_01 -radix hexadecimal /entropy_encoding_tb/DUT/CL01/c01
add wave -noupdate -expand -group CL_01 -radix hexadecimal /entropy_encoding_tb/DUT/CL01/c09
add wave -noupdate -expand -group CL_01 -radix hexadecimal /entropy_encoding_tb/DUT/CL01/c10
add wave -noupdate -expand -group CL_01 -radix hexadecimal /entropy_encoding_tb/DUT/CL01/c30
add wave -noupdate -expand -group CL_01 -radix hexadecimal /entropy_encoding_tb/DUT/CL01/c50
add wave -noupdate -expand -group CL_01 -radix hexadecimal /entropy_encoding_tb/DUT/CL01/c52
add wave -noupdate -expand -group CL_01 -radix hexadecimal /entropy_encoding_tb/DUT/CL01/c53
add wave -noupdate -expand -group CL_01 -radix hexadecimal /entropy_encoding_tb/DUT/CL01/c60
add wave -noupdate -expand -group CL_01 -radix hexadecimal /entropy_encoding_tb/DUT/CL01/c61
add wave -noupdate -expand -group CL_01 -radix hexadecimal -childformat {{/entropy_encoding_tb/DUT/CL01/c70(19) -radix hexadecimal} {/entropy_encoding_tb/DUT/CL01/c70(18) -radix hexadecimal} {/entropy_encoding_tb/DUT/CL01/c70(17) -radix hexadecimal} {/entropy_encoding_tb/DUT/CL01/c70(16) -radix hexadecimal} {/entropy_encoding_tb/DUT/CL01/c70(15) -radix hexadecimal} {/entropy_encoding_tb/DUT/CL01/c70(14) -radix hexadecimal} {/entropy_encoding_tb/DUT/CL01/c70(13) -radix hexadecimal} {/entropy_encoding_tb/DUT/CL01/c70(12) -radix hexadecimal} {/entropy_encoding_tb/DUT/CL01/c70(11) -radix hexadecimal} {/entropy_encoding_tb/DUT/CL01/c70(10) -radix hexadecimal} {/entropy_encoding_tb/DUT/CL01/c70(9) -radix hexadecimal} {/entropy_encoding_tb/DUT/CL01/c70(8) -radix hexadecimal} {/entropy_encoding_tb/DUT/CL01/c70(7) -radix hexadecimal} {/entropy_encoding_tb/DUT/CL01/c70(6) -radix hexadecimal} {/entropy_encoding_tb/DUT/CL01/c70(5) -radix hexadecimal} {/entropy_encoding_tb/DUT/CL01/c70(4) -radix hexadecimal} {/entropy_encoding_tb/DUT/CL01/c70(3) -radix hexadecimal} {/entropy_encoding_tb/DUT/CL01/c70(2) -radix hexadecimal} {/entropy_encoding_tb/DUT/CL01/c70(1) -radix hexadecimal} {/entropy_encoding_tb/DUT/CL01/c70(0) -radix hexadecimal}} -subitemconfig {/entropy_encoding_tb/DUT/CL01/c70(19) {-height 16 -radix hexadecimal} /entropy_encoding_tb/DUT/CL01/c70(18) {-height 16 -radix hexadecimal} /entropy_encoding_tb/DUT/CL01/c70(17) {-height 16 -radix hexadecimal} /entropy_encoding_tb/DUT/CL01/c70(16) {-height 16 -radix hexadecimal} /entropy_encoding_tb/DUT/CL01/c70(15) {-height 16 -radix hexadecimal} /entropy_encoding_tb/DUT/CL01/c70(14) {-height 16 -radix hexadecimal} /entropy_encoding_tb/DUT/CL01/c70(13) {-height 16 -radix hexadecimal} /entropy_encoding_tb/DUT/CL01/c70(12) {-height 16 -radix hexadecimal} /entropy_encoding_tb/DUT/CL01/c70(11) {-height 16 -radix hexadecimal} /entropy_encoding_tb/DUT/CL01/c70(10) {-height 16 -radix hexadecimal} /entropy_encoding_tb/DUT/CL01/c70(9) {-height 16 -radix hexadecimal} /entropy_encoding_tb/DUT/CL01/c70(8) {-height 16 -radix hexadecimal} /entropy_encoding_tb/DUT/CL01/c70(7) {-height 16 -radix hexadecimal} /entropy_encoding_tb/DUT/CL01/c70(6) {-height 16 -radix hexadecimal} /entropy_encoding_tb/DUT/CL01/c70(5) {-height 16 -radix hexadecimal} /entropy_encoding_tb/DUT/CL01/c70(4) {-height 16 -radix hexadecimal} /entropy_encoding_tb/DUT/CL01/c70(3) {-height 16 -radix hexadecimal} /entropy_encoding_tb/DUT/CL01/c70(2) {-height 16 -radix hexadecimal} /entropy_encoding_tb/DUT/CL01/c70(1) {-height 16 -radix hexadecimal} /entropy_encoding_tb/DUT/CL01/c70(0) {-height 16 -radix hexadecimal}} /entropy_encoding_tb/DUT/CL01/c70
add wave -noupdate -expand -group CL_01 -radix hexadecimal /entropy_encoding_tb/DUT/CL01/c80
add wave -noupdate -expand -group CL_01 -radix hexadecimal /entropy_encoding_tb/DUT/CL01/c80_ovf
add wave -noupdate -expand -group CL_01 -radix hexadecimal /entropy_encoding_tb/DUT/CL01/d_out
add wave -noupdate -expand -group CL_01 -radix hexadecimal /entropy_encoding_tb/DUT/CL01/en_out
add wave -noupdate -expand -group CL_01 -radix hexadecimal /entropy_encoding_tb/DUT/CL01/sof_out
add wave -noupdate -expand -group PCAs -radix decimal /entropy_encoding_tb/DUT/pca_d01_out
add wave -noupdate -expand -group PCAs -radix decimal /entropy_encoding_tb/DUT/pca_d02_out
add wave -noupdate -expand -group PCAs -radix decimal /entropy_encoding_tb/DUT/pca_d03_out
add wave -noupdate -expand -group PCAs -radix decimal /entropy_encoding_tb/DUT/pca_d04_out
add wave -noupdate -expand -group PCAs -radix hexadecimal /entropy_encoding_tb/DUT/pca_en_out
add wave -noupdate -expand -group PCAs -radix hexadecimal /entropy_encoding_tb/DUT/pca_sof_out
add wave -noupdate -expand -group Buff_01 -radix hexadecimal /entropy_encoding_tb/DUT/Huffman64_inst/Buf01/enw
add wave -noupdate -expand -group Buff_01 -radix hexadecimal /entropy_encoding_tb/DUT/Huffman64_inst/Buf01/data_in
add wave -noupdate -expand -group Buff_01 -radix hexadecimal /entropy_encoding_tb/DUT/Huffman64_inst/Buf01/enr
add wave -noupdate -expand -group Buff_01 -radix hexadecimal /entropy_encoding_tb/DUT/Huffman64_inst/Buf01/data_out
add wave -noupdate -expand -group Buff_01 -radix hexadecimal /entropy_encoding_tb/DUT/Huffman64_inst/Buf01/burst_r
add wave -noupdate -expand -group Buff_01 -radix hexadecimal /entropy_encoding_tb/DUT/Huffman64_inst/Buf01/fifo_empty
add wave -noupdate -expand -group Buff_01 -radix hexadecimal /entropy_encoding_tb/DUT/Huffman64_inst/Buf01/fifo_full
add wave -noupdate -radix hexadecimal /entropy_encoding_tb/DUT/Huffman64_inst/b_rd
add wave -noupdate -radix hexadecimal /entropy_encoding_tb/DUT/Huffman64_inst/d_out
add wave -noupdate /entropy_encoding_tb/DUT/PCA_en
add wave -noupdate /entropy_encoding_tb/DUT/cl_en_out
add wave -noupdate /entropy_encoding_tb/DUT/pca_en_out
add wave -noupdate -radix hexadecimal /entropy_encoding_tb/DUT/d01_out1
add wave -noupdate -radix hexadecimal -childformat {{/entropy_encoding_tb/DUT/d01_out(19) -radix hexadecimal} {/entropy_encoding_tb/DUT/d01_out(18) -radix hexadecimal} {/entropy_encoding_tb/DUT/d01_out(17) -radix hexadecimal} {/entropy_encoding_tb/DUT/d01_out(16) -radix hexadecimal} {/entropy_encoding_tb/DUT/d01_out(15) -radix hexadecimal} {/entropy_encoding_tb/DUT/d01_out(14) -radix hexadecimal} {/entropy_encoding_tb/DUT/d01_out(13) -radix hexadecimal} {/entropy_encoding_tb/DUT/d01_out(12) -radix hexadecimal} {/entropy_encoding_tb/DUT/d01_out(11) -radix hexadecimal} {/entropy_encoding_tb/DUT/d01_out(10) -radix hexadecimal} {/entropy_encoding_tb/DUT/d01_out(9) -radix hexadecimal} {/entropy_encoding_tb/DUT/d01_out(8) -radix hexadecimal} {/entropy_encoding_tb/DUT/d01_out(7) -radix hexadecimal} {/entropy_encoding_tb/DUT/d01_out(6) -radix hexadecimal} {/entropy_encoding_tb/DUT/d01_out(5) -radix hexadecimal} {/entropy_encoding_tb/DUT/d01_out(4) -radix hexadecimal} {/entropy_encoding_tb/DUT/d01_out(3) -radix hexadecimal} {/entropy_encoding_tb/DUT/d01_out(2) -radix hexadecimal} {/entropy_encoding_tb/DUT/d01_out(1) -radix hexadecimal} {/entropy_encoding_tb/DUT/d01_out(0) -radix hexadecimal}} -subitemconfig {/entropy_encoding_tb/DUT/d01_out(19) {-radix hexadecimal} /entropy_encoding_tb/DUT/d01_out(18) {-radix hexadecimal} /entropy_encoding_tb/DUT/d01_out(17) {-radix hexadecimal} /entropy_encoding_tb/DUT/d01_out(16) {-radix hexadecimal} /entropy_encoding_tb/DUT/d01_out(15) {-radix hexadecimal} /entropy_encoding_tb/DUT/d01_out(14) {-radix hexadecimal} /entropy_encoding_tb/DUT/d01_out(13) {-radix hexadecimal} /entropy_encoding_tb/DUT/d01_out(12) {-radix hexadecimal} /entropy_encoding_tb/DUT/d01_out(11) {-radix hexadecimal} /entropy_encoding_tb/DUT/d01_out(10) {-radix hexadecimal} /entropy_encoding_tb/DUT/d01_out(9) {-radix hexadecimal} /entropy_encoding_tb/DUT/d01_out(8) {-radix hexadecimal} /entropy_encoding_tb/DUT/d01_out(7) {-radix hexadecimal} /entropy_encoding_tb/DUT/d01_out(6) {-radix hexadecimal} /entropy_encoding_tb/DUT/d01_out(5) {-radix hexadecimal} /entropy_encoding_tb/DUT/d01_out(4) {-radix hexadecimal} /entropy_encoding_tb/DUT/d01_out(3) {-radix hexadecimal} /entropy_encoding_tb/DUT/d01_out(2) {-radix hexadecimal} /entropy_encoding_tb/DUT/d01_out(1) {-radix hexadecimal} /entropy_encoding_tb/DUT/d01_out(0) {-radix hexadecimal}} /entropy_encoding_tb/DUT/d01_out
add wave -noupdate -radix hexadecimal /entropy_encoding_tb/DUT/pca_d01_out
add wave -noupdate /entropy_encoding_tb/DUT/Huff_enc_en
add wave -noupdate -radix hexadecimal /entropy_encoding_tb/DUT/Huffman64_inst/d01_in
add wave -noupdate -radix hexadecimal /entropy_encoding_tb/DUT/Huffman64_inst/h01_out
add wave -noupdate /entropy_encoding_tb/DUT/Huffman64_inst/en_in
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3895000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 389
configure wave -valuecolwidth 223
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {1254388 ps} {5197138 ps}

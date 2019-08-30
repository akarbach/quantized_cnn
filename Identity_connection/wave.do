onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /identity_connection_tb/w_unit_n
add wave -noupdate -radix unsigned /identity_connection_tb/w_in
add wave -noupdate -radix unsigned /identity_connection_tb/w_num
add wave -noupdate -radix unsigned /identity_connection_tb/w_en
add wave -noupdate -radix unsigned /identity_connection_tb/w_lin_rdy
add wave -noupdate -radix unsigned /identity_connection_tb/w_CL_select
add wave -noupdate -radix unsigned /identity_connection_tb/DUT/w_unit_n_s
add wave -noupdate -radix unsigned /identity_connection_tb/DUT/w_in_s
add wave -noupdate -radix unsigned /identity_connection_tb/DUT/w_num_s
add wave -noupdate -radix unsigned -childformat {{/identity_connection_tb/DUT/w_en_s(7) -radix unsigned} {/identity_connection_tb/DUT/w_en_s(6) -radix unsigned} {/identity_connection_tb/DUT/w_en_s(5) -radix unsigned} {/identity_connection_tb/DUT/w_en_s(4) -radix unsigned} {/identity_connection_tb/DUT/w_en_s(3) -radix unsigned} {/identity_connection_tb/DUT/w_en_s(2) -radix unsigned} {/identity_connection_tb/DUT/w_en_s(1) -radix unsigned} {/identity_connection_tb/DUT/w_en_s(0) -radix unsigned}} -expand -subitemconfig {/identity_connection_tb/DUT/w_en_s(7) {-height 17 -radix unsigned} /identity_connection_tb/DUT/w_en_s(6) {-height 17 -radix unsigned} /identity_connection_tb/DUT/w_en_s(5) {-height 17 -radix unsigned} /identity_connection_tb/DUT/w_en_s(4) {-height 17 -radix unsigned} /identity_connection_tb/DUT/w_en_s(3) {-height 17 -radix unsigned} /identity_connection_tb/DUT/w_en_s(2) {-height 17 -radix unsigned} /identity_connection_tb/DUT/w_en_s(1) {-height 17 -radix unsigned} /identity_connection_tb/DUT/w_en_s(0) {-height 17 -radix unsigned}} /identity_connection_tb/DUT/w_en_s
add wave -noupdate -divider {CL first}
add wave -noupdate /identity_connection_tb/DUT/CL_first/w_en
add wave -noupdate -radix decimal /identity_connection_tb/DUT/CL_first/d_in
add wave -noupdate -radix decimal /identity_connection_tb/DUT/CL_first/en_in
add wave -noupdate -radix decimal /identity_connection_tb/DUT/CL_first/d_out1
add wave -noupdate -radix decimal /identity_connection_tb/DUT/CL_first/d_out
add wave -noupdate -radix decimal /identity_connection_tb/DUT/CL_first/en_out
add wave -noupdate -divider {CL int}
add wave -noupdate -radix decimal /identity_connection_tb/DUT/d_in1
add wave -noupdate -divider {CL last}
add wave -noupdate /identity_connection_tb/DUT/CL_last/w_en
add wave -noupdate /identity_connection_tb/DUT/CL_last/w1
add wave -noupdate /identity_connection_tb/DUT/CL_last/w2
add wave -noupdate /identity_connection_tb/DUT/CL_last/w3
add wave -noupdate /identity_connection_tb/DUT/CL_last/w4
add wave -noupdate /identity_connection_tb/DUT/CL_last/w5
add wave -noupdate /identity_connection_tb/DUT/CL_last/w_in
add wave -noupdate -radix decimal /identity_connection_tb/DUT/CL_last/d_in
add wave -noupdate -radix decimal /identity_connection_tb/DUT/CL_last/en_in
add wave -noupdate -radix decimal -childformat {{/identity_connection_tb/DUT/CL_last/d_out1(0) -radix decimal} {/identity_connection_tb/DUT/CL_last/d_out1(1) -radix decimal} {/identity_connection_tb/DUT/CL_last/d_out1(2) -radix decimal} {/identity_connection_tb/DUT/CL_last/d_out1(3) -radix decimal}} -expand -subitemconfig {/identity_connection_tb/DUT/CL_last/d_out1(0) {-radix decimal} /identity_connection_tb/DUT/CL_last/d_out1(1) {-radix decimal} /identity_connection_tb/DUT/CL_last/d_out1(2) {-radix decimal} /identity_connection_tb/DUT/CL_last/d_out1(3) {-radix decimal}} /identity_connection_tb/DUT/CL_last/d_out1
add wave -noupdate -radix decimal /identity_connection_tb/DUT/CL_last/d_out
add wave -noupdate -radix decimal /identity_connection_tb/DUT/CL_last/en_out
add wave -noupdate -divider ADDER
add wave -noupdate -radix decimal -childformat {{/identity_connection_tb/DUT/short_out(0) -radix decimal} {/identity_connection_tb/DUT/short_out(1) -radix decimal} {/identity_connection_tb/DUT/short_out(2) -radix decimal} {/identity_connection_tb/DUT/short_out(3) -radix decimal}} -expand -subitemconfig {/identity_connection_tb/DUT/short_out(0) {-height 17 -radix decimal} /identity_connection_tb/DUT/short_out(1) {-height 17 -radix decimal} /identity_connection_tb/DUT/short_out(2) {-height 17 -radix decimal} /identity_connection_tb/DUT/short_out(3) {-height 17 -radix decimal}} /identity_connection_tb/DUT/short_out
add wave -noupdate -radix decimal /identity_connection_tb/DUT/d_s
add wave -noupdate -radix decimal /identity_connection_tb/DUT/en_s
add wave -noupdate -radix decimal -childformat {{/identity_connection_tb/DUT/d_sum(0) -radix decimal -childformat {{/identity_connection_tb/DUT/d_sum(0)(8) -radix decimal} {/identity_connection_tb/DUT/d_sum(0)(7) -radix decimal} {/identity_connection_tb/DUT/d_sum(0)(6) -radix decimal} {/identity_connection_tb/DUT/d_sum(0)(5) -radix decimal} {/identity_connection_tb/DUT/d_sum(0)(4) -radix decimal} {/identity_connection_tb/DUT/d_sum(0)(3) -radix decimal} {/identity_connection_tb/DUT/d_sum(0)(2) -radix decimal} {/identity_connection_tb/DUT/d_sum(0)(1) -radix decimal} {/identity_connection_tb/DUT/d_sum(0)(0) -radix decimal}}} {/identity_connection_tb/DUT/d_sum(1) -radix decimal -childformat {{/identity_connection_tb/DUT/d_sum(1)(8) -radix decimal} {/identity_connection_tb/DUT/d_sum(1)(7) -radix decimal} {/identity_connection_tb/DUT/d_sum(1)(6) -radix decimal} {/identity_connection_tb/DUT/d_sum(1)(5) -radix decimal} {/identity_connection_tb/DUT/d_sum(1)(4) -radix decimal} {/identity_connection_tb/DUT/d_sum(1)(3) -radix decimal} {/identity_connection_tb/DUT/d_sum(1)(2) -radix decimal} {/identity_connection_tb/DUT/d_sum(1)(1) -radix decimal} {/identity_connection_tb/DUT/d_sum(1)(0) -radix decimal}}} {/identity_connection_tb/DUT/d_sum(2) -radix decimal} {/identity_connection_tb/DUT/d_sum(3) -radix decimal}} -expand -subitemconfig {/identity_connection_tb/DUT/d_sum(0) {-height 17 -radix decimal -childformat {{/identity_connection_tb/DUT/d_sum(0)(8) -radix decimal} {/identity_connection_tb/DUT/d_sum(0)(7) -radix decimal} {/identity_connection_tb/DUT/d_sum(0)(6) -radix decimal} {/identity_connection_tb/DUT/d_sum(0)(5) -radix decimal} {/identity_connection_tb/DUT/d_sum(0)(4) -radix decimal} {/identity_connection_tb/DUT/d_sum(0)(3) -radix decimal} {/identity_connection_tb/DUT/d_sum(0)(2) -radix decimal} {/identity_connection_tb/DUT/d_sum(0)(1) -radix decimal} {/identity_connection_tb/DUT/d_sum(0)(0) -radix decimal}}} /identity_connection_tb/DUT/d_sum(0)(8) {-height 17 -radix decimal} /identity_connection_tb/DUT/d_sum(0)(7) {-height 17 -radix decimal} /identity_connection_tb/DUT/d_sum(0)(6) {-height 17 -radix decimal} /identity_connection_tb/DUT/d_sum(0)(5) {-height 17 -radix decimal} /identity_connection_tb/DUT/d_sum(0)(4) {-height 17 -radix decimal} /identity_connection_tb/DUT/d_sum(0)(3) {-height 17 -radix decimal} /identity_connection_tb/DUT/d_sum(0)(2) {-height 17 -radix decimal} /identity_connection_tb/DUT/d_sum(0)(1) {-height 17 -radix decimal} /identity_connection_tb/DUT/d_sum(0)(0) {-height 17 -radix decimal} /identity_connection_tb/DUT/d_sum(1) {-height 17 -radix decimal -childformat {{/identity_connection_tb/DUT/d_sum(1)(8) -radix decimal} {/identity_connection_tb/DUT/d_sum(1)(7) -radix decimal} {/identity_connection_tb/DUT/d_sum(1)(6) -radix decimal} {/identity_connection_tb/DUT/d_sum(1)(5) -radix decimal} {/identity_connection_tb/DUT/d_sum(1)(4) -radix decimal} {/identity_connection_tb/DUT/d_sum(1)(3) -radix decimal} {/identity_connection_tb/DUT/d_sum(1)(2) -radix decimal} {/identity_connection_tb/DUT/d_sum(1)(1) -radix decimal} {/identity_connection_tb/DUT/d_sum(1)(0) -radix decimal}}} /identity_connection_tb/DUT/d_sum(1)(8) {-height 17 -radix decimal} /identity_connection_tb/DUT/d_sum(1)(7) {-height 17 -radix decimal} /identity_connection_tb/DUT/d_sum(1)(6) {-height 17 -radix decimal} /identity_connection_tb/DUT/d_sum(1)(5) {-height 17 -radix decimal} /identity_connection_tb/DUT/d_sum(1)(4) {-height 17 -radix decimal} /identity_connection_tb/DUT/d_sum(1)(3) {-height 17 -radix decimal} /identity_connection_tb/DUT/d_sum(1)(2) {-height 17 -radix decimal} /identity_connection_tb/DUT/d_sum(1)(1) {-height 17 -radix decimal} /identity_connection_tb/DUT/d_sum(1)(0) {-height 17 -radix decimal} /identity_connection_tb/DUT/d_sum(2) {-height 17 -radix decimal} /identity_connection_tb/DUT/d_sum(3) {-height 17 -radix decimal}} /identity_connection_tb/DUT/d_sum
add wave -noupdate -radix decimal /identity_connection_tb/DUT/d_relu
add wave -noupdate -radix decimal -childformat {{/identity_connection_tb/DUT/d_out(0) -radix decimal} {/identity_connection_tb/DUT/d_out(1) -radix decimal} {/identity_connection_tb/DUT/d_out(2) -radix decimal} {/identity_connection_tb/DUT/d_out(3) -radix decimal}} -expand -subitemconfig {/identity_connection_tb/DUT/d_out(0) {-height 17 -radix decimal} /identity_connection_tb/DUT/d_out(1) {-height 17 -radix decimal} /identity_connection_tb/DUT/d_out(2) {-height 17 -radix decimal} /identity_connection_tb/DUT/d_out(3) {-height 17 -radix decimal}} /identity_connection_tb/DUT/d_out
add wave -noupdate -expand /identity_connection_tb/DUT/d_conv
add wave -noupdate /identity_connection_tb/DUT/en_conv
add wave -noupdate /identity_connection_tb/DUT/sof_conv
add wave -noupdate -divider {Max Pool}
add wave -noupdate -radix decimal /identity_connection_tb/DUT/pooling_yes/pool_gen(0)/Pool/d_in
add wave -noupdate -radix decimal /identity_connection_tb/DUT/pooling_yes/pool_gen(0)/Pool/en_in
add wave -noupdate -radix decimal /identity_connection_tb/DUT/pooling_yes/pool_gen(0)/Pool/data2pool1
add wave -noupdate -radix decimal /identity_connection_tb/DUT/pooling_yes/pool_gen(0)/Pool/data2pool2
add wave -noupdate -radix decimal /identity_connection_tb/DUT/pooling_yes/pool_gen(0)/Pool/data2pool3
add wave -noupdate -radix decimal /identity_connection_tb/DUT/pooling_yes/pool_gen(0)/Pool/data2pool4
add wave -noupdate -radix decimal /identity_connection_tb/DUT/pooling_yes/pool_gen(0)/Pool/data2pool5
add wave -noupdate -radix decimal /identity_connection_tb/DUT/pooling_yes/pool_gen(0)/Pool/data2pool6
add wave -noupdate -radix decimal /identity_connection_tb/DUT/pooling_yes/pool_gen(0)/Pool/data2pool7
add wave -noupdate -radix decimal /identity_connection_tb/DUT/pooling_yes/pool_gen(0)/Pool/data2pool8
add wave -noupdate -radix decimal /identity_connection_tb/DUT/pooling_yes/pool_gen(0)/Pool/data2pool9
add wave -noupdate -radix decimal /identity_connection_tb/DUT/pooling_yes/pool_gen(0)/Pool/maxpool_en
add wave -noupdate -radix decimal -childformat {{/identity_connection_tb/DUT/pooling_yes/pool_gen(0)/Pool/d_out(7) -radix decimal} {/identity_connection_tb/DUT/pooling_yes/pool_gen(0)/Pool/d_out(6) -radix decimal} {/identity_connection_tb/DUT/pooling_yes/pool_gen(0)/Pool/d_out(5) -radix decimal} {/identity_connection_tb/DUT/pooling_yes/pool_gen(0)/Pool/d_out(4) -radix decimal} {/identity_connection_tb/DUT/pooling_yes/pool_gen(0)/Pool/d_out(3) -radix decimal} {/identity_connection_tb/DUT/pooling_yes/pool_gen(0)/Pool/d_out(2) -radix decimal} {/identity_connection_tb/DUT/pooling_yes/pool_gen(0)/Pool/d_out(1) -radix decimal} {/identity_connection_tb/DUT/pooling_yes/pool_gen(0)/Pool/d_out(0) -radix decimal}} -subitemconfig {/identity_connection_tb/DUT/pooling_yes/pool_gen(0)/Pool/d_out(7) {-radix decimal} /identity_connection_tb/DUT/pooling_yes/pool_gen(0)/Pool/d_out(6) {-radix decimal} /identity_connection_tb/DUT/pooling_yes/pool_gen(0)/Pool/d_out(5) {-radix decimal} /identity_connection_tb/DUT/pooling_yes/pool_gen(0)/Pool/d_out(4) {-radix decimal} /identity_connection_tb/DUT/pooling_yes/pool_gen(0)/Pool/d_out(3) {-radix decimal} /identity_connection_tb/DUT/pooling_yes/pool_gen(0)/Pool/d_out(2) {-radix decimal} /identity_connection_tb/DUT/pooling_yes/pool_gen(0)/Pool/d_out(1) {-radix decimal} /identity_connection_tb/DUT/pooling_yes/pool_gen(0)/Pool/d_out(0) {-radix decimal}} /identity_connection_tb/DUT/pooling_yes/pool_gen(0)/Pool/d_out
add wave -noupdate /identity_connection_tb/DUT/pooling_yes/pool_gen(0)/Pool/en_out
add wave -noupdate -expand /identity_connection_tb/DUT/maxpool_en1
add wave -noupdate /identity_connection_tb/DUT/maxpool_sof1
add wave -noupdate -radix decimal /identity_connection_tb/DUT/en_out
add wave -noupdate -radix decimal -childformat {{/identity_connection_tb/d_in(0) -radix decimal} {/identity_connection_tb/d_in(1) -radix decimal} {/identity_connection_tb/d_in(2) -radix decimal} {/identity_connection_tb/d_in(3) -radix decimal}} -subitemconfig {/identity_connection_tb/d_in(0) {-height 17 -radix decimal} /identity_connection_tb/d_in(1) {-height 17 -radix decimal} /identity_connection_tb/d_in(2) {-height 17 -radix decimal} /identity_connection_tb/d_in(3) {-height 17 -radix decimal}} /identity_connection_tb/d_in
add wave -noupdate /identity_connection_tb/en_in
add wave -noupdate -radix decimal /identity_connection_tb/d_out
add wave -noupdate -radix decimal /identity_connection_tb/en_out
add wave -noupdate -divider {Pool 2}
add wave -noupdate -radix decimal /identity_connection_tb/DUT/pooling_yes/pool_gen(1)/Pool/d_in
add wave -noupdate -radix decimal /identity_connection_tb/DUT/pooling_yes/pool_gen(1)/Pool/en_in
add wave -noupdate -radix decimal /identity_connection_tb/DUT/pooling_yes/pool_gen(1)/Pool/data2pool1
add wave -noupdate -radix decimal /identity_connection_tb/DUT/pooling_yes/pool_gen(1)/Pool/data2pool2
add wave -noupdate -radix decimal /identity_connection_tb/DUT/pooling_yes/pool_gen(1)/Pool/data2pool3
add wave -noupdate -radix decimal /identity_connection_tb/DUT/pooling_yes/pool_gen(1)/Pool/data2pool4
add wave -noupdate -radix decimal /identity_connection_tb/DUT/pooling_yes/pool_gen(1)/Pool/data2pool5
add wave -noupdate -radix decimal /identity_connection_tb/DUT/pooling_yes/pool_gen(1)/Pool/data2pool6
add wave -noupdate -radix decimal /identity_connection_tb/DUT/pooling_yes/pool_gen(1)/Pool/data2pool7
add wave -noupdate -radix decimal /identity_connection_tb/DUT/pooling_yes/pool_gen(1)/Pool/data2pool8
add wave -noupdate -radix decimal /identity_connection_tb/DUT/pooling_yes/pool_gen(1)/Pool/data2pool9
add wave -noupdate -radix decimal /identity_connection_tb/DUT/pooling_yes/pool_gen(1)/Pool/d_out
add wave -noupdate -radix decimal /identity_connection_tb/DUT/pooling_yes/pool_gen(1)/Pool/en_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {15460630 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 110
configure wave -valuecolwidth 306
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
WaveRestoreZoom {0 ps} {21 us}

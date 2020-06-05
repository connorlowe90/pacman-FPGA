onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ghosts_loc_ctrl_testbench/CLOCK_50
add wave -noupdate /ghosts_loc_ctrl_testbench/reset
add wave -noupdate /ghosts_loc_ctrl_testbench/dut/ready
add wave -noupdate /ghosts_loc_ctrl_testbench/wrdone
add wave -noupdate -radix unsigned /ghosts_loc_ctrl_testbench/next_ghost2_y
add wave -noupdate -radix unsigned /ghosts_loc_ctrl_testbench/next_ghost2_x
add wave -noupdate -radix unsigned /ghosts_loc_ctrl_testbench/next_ghost1_y
add wave -noupdate -radix unsigned /ghosts_loc_ctrl_testbench/next_ghost1_x
add wave -noupdate -radix unsigned /ghosts_loc_ctrl_testbench/curr_pacman_y
add wave -noupdate -radix unsigned /ghosts_loc_ctrl_testbench/curr_pacman_x
add wave -noupdate -radix unsigned /ghosts_loc_ctrl_testbench/dut/next_ghost1_val4
add wave -noupdate -radix unsigned /ghosts_loc_ctrl_testbench/dut/next_ghost1_val3
add wave -noupdate -radix unsigned /ghosts_loc_ctrl_testbench/dut/next_ghost1_val2
add wave -noupdate -radix unsigned /ghosts_loc_ctrl_testbench/dut/next_ghost1_val1
add wave -noupdate -radix unsigned /ghosts_loc_ctrl_testbench/dut/next_ghost2_val4
add wave -noupdate -radix unsigned /ghosts_loc_ctrl_testbench/dut/next_ghost2_val3
add wave -noupdate -radix unsigned /ghosts_loc_ctrl_testbench/dut/next_ghost2_val2
add wave -noupdate -radix unsigned /ghosts_loc_ctrl_testbench/dut/next_ghost2_val1
add wave -noupdate -radix unsigned /ghosts_loc_ctrl_testbench/dut/prev_ghost1_y
add wave -noupdate -radix unsigned /ghosts_loc_ctrl_testbench/dut/prev_ghost1_x
add wave -noupdate -radix unsigned /ghosts_loc_ctrl_testbench/dut/curr_ghost1_y
add wave -noupdate -radix unsigned /ghosts_loc_ctrl_testbench/dut/curr_ghost1_x
add wave -noupdate -radix unsigned /ghosts_loc_ctrl_testbench/dut/next_ghost1_y
add wave -noupdate -radix unsigned /ghosts_loc_ctrl_testbench/dut/next_ghost1_x
add wave -noupdate -radix unsigned /ghosts_loc_ctrl_testbench/dut/prev_ghost2_y
add wave -noupdate -radix unsigned /ghosts_loc_ctrl_testbench/dut/prev_ghost2_x
add wave -noupdate -radix unsigned /ghosts_loc_ctrl_testbench/dut/curr_ghost2_y
add wave -noupdate -radix unsigned /ghosts_loc_ctrl_testbench/dut/curr_ghost2_x
add wave -noupdate -radix unsigned /ghosts_loc_ctrl_testbench/dut/next_ghost2_y
add wave -noupdate -radix unsigned /ghosts_loc_ctrl_testbench/dut/next_ghost2_x
add wave -noupdate -radix unsigned /ghosts_loc_ctrl_testbench/dut/next_ghost1_min_y
add wave -noupdate -radix unsigned /ghosts_loc_ctrl_testbench/dut/next_ghost1_min_x
add wave -noupdate -radix unsigned /ghosts_loc_ctrl_testbench/dut/next_ghost2_min_y
add wave -noupdate -radix unsigned /ghosts_loc_ctrl_testbench/dut/next_ghost2_min_x
add wave -noupdate -radix unsigned /ghosts_loc_ctrl_testbench/dut/count
add wave -noupdate /ghosts_loc_ctrl_testbench/dut/ps
add wave -noupdate /ghosts_loc_ctrl_testbench/dut/ns
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {241329 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 50
configure wave -gridperiod 100
configure wave -griddelta 20
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {240750 ps} {244750 ps}

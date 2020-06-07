onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /pacman_loc_ctrl_testbench/reset
add wave -noupdate /pacman_loc_ctrl_testbench/CLOCK_50
add wave -noupdate /pacman_loc_ctrl_testbench/direction
add wave -noupdate /pacman_loc_ctrl_testbench/up
add wave -noupdate /pacman_loc_ctrl_testbench/right
add wave -noupdate /pacman_loc_ctrl_testbench/left
add wave -noupdate /pacman_loc_ctrl_testbench/down
add wave -noupdate /pacman_loc_ctrl_testbench/done
add wave -noupdate -radix unsigned /pacman_loc_ctrl_testbench/curr_pacman_x
add wave -noupdate -radix unsigned /pacman_loc_ctrl_testbench/curr_pacman_y
add wave -noupdate -radix unsigned /pacman_loc_ctrl_testbench/next_pacman_x
add wave -noupdate -radix unsigned /pacman_loc_ctrl_testbench/next_pacman_y
add wave -noupdate /pacman_loc_ctrl_testbench/dut/collision_type
add wave -noupdate /pacman_loc_ctrl_testbench/dut/ps
add wave -noupdate /pacman_loc_ctrl_testbench/dut/ns
add wave -noupdate /pacman_loc_ctrl_testbench/pill_count
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5125 ps} 0}
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
WaveRestoreZoom {0 ps} {2678 ps}

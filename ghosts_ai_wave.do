onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ghosts_ai_testbench/CLOCK_50
add wave -noupdate /ghosts_ai_testbench/wrdone
add wave -noupdate /ghosts_ai_testbench/reset
add wave -noupdate /ghosts_ai_testbench/enable
add wave -noupdate -radix unsigned /ghosts_ai_testbench/next_ghost2_y
add wave -noupdate -radix unsigned /ghosts_ai_testbench/next_ghost2_x
add wave -noupdate -radix unsigned /ghosts_ai_testbench/next_ghost1_y
add wave -noupdate -radix unsigned /ghosts_ai_testbench/next_ghost1_x
add wave -noupdate -radix unsigned /ghosts_ai_testbench/curr_ghost2_y
add wave -noupdate -radix unsigned /ghosts_ai_testbench/curr_ghost2_x
add wave -noupdate -radix unsigned /ghosts_ai_testbench/curr_ghost1_y
add wave -noupdate -radix unsigned /ghosts_ai_testbench/curr_ghost1_x
add wave -noupdate -radix unsigned /ghosts_ai_testbench/curr_pacman_y
add wave -noupdate -radix unsigned /ghosts_ai_testbench/curr_pacman_x
add wave -noupdate /ghosts_ai_testbench/dut/ps
add wave -noupdate /ghosts_ai_testbench/dut/ns
add wave -noupdate /ghosts_ai_testbench/dut/next_ghost2_min_y
add wave -noupdate /ghosts_ai_testbench/dut/next_ghost2_min_x
add wave -noupdate /ghosts_ai_testbench/dut/next_ghost2_min_val
add wave -noupdate /ghosts_ai_testbench/dut/main_map_reg1
add wave -noupdate /ghosts_ai_testbench/dut/main_map_reg2
add wave -noupdate -radix unsigned /ghosts_ai_testbench/dut/main_map_grid
add wave -noupdate /ghosts_ai_testbench/dut/main_map_out
add wave -noupdate /ghosts_ai_testbench/dut/rdaddr_y
add wave -noupdate /ghosts_ai_testbench/dut/rdaddr_x
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6509 ps} 0}
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
WaveRestoreZoom {5524 ps} {12426 ps}

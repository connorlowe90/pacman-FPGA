onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ghost_RAM_ctrl_testbench/CLOCK_50
add wave -noupdate /ghost_RAM_ctrl_testbench/reset
add wave -noupdate /ghost_RAM_ctrl_testbench/ready
add wave -noupdate /ghost_RAM_ctrl_testbench/dut/wren
add wave -noupdate -radix unsigned /ghost_RAM_ctrl_testbench/curr_pacman_x
add wave -noupdate -radix unsigned /ghost_RAM_ctrl_testbench/curr_pacman_y
add wave -noupdate -radix unsigned /ghost_RAM_ctrl_testbench/dut/glob_x
add wave -noupdate -radix unsigned /ghost_RAM_ctrl_testbench/dut/glob_y
add wave -noupdate /ghost_RAM_ctrl_testbench/dut/main_map_word
add wave -noupdate -radix unsigned /ghost_RAM_ctrl_testbench/dut/main_map_grid
add wave -noupdate -radix unsigned /ghost_RAM_ctrl_testbench/dut/wr_ghost_grid
add wave -noupdate /ghost_RAM_ctrl_testbench/dut/wr_ghost_word
add wave -noupdate /ghost_RAM_ctrl_testbench/dut/ps
add wave -noupdate /ghost_RAM_ctrl_testbench/dut/ns
add wave -noupdate -radix unsigned /ghost_RAM_ctrl_testbench/rdaddr_y
add wave -noupdate -radix unsigned /ghost_RAM_ctrl_testbench/rdaddr_x
add wave -noupdate -radix unsigned /ghost_RAM_ctrl_testbench/data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {240513 ps} 0}
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
WaveRestoreZoom {230015 ps} {241737 ps}

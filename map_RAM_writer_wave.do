onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /map_RAM_writer_testbench/direction
add wave -noupdate /map_RAM_writer_testbench/reset
add wave -noupdate -radix unsigned /map_RAM_writer_testbench/curr_pacman_y
add wave -noupdate -radix unsigned /map_RAM_writer_testbench/curr_pacman_x
add wave -noupdate -radix unsigned /map_RAM_writer_testbench/next_pacman_y
add wave -noupdate -radix unsigned /map_RAM_writer_testbench/next_pacman_x
add wave -noupdate /map_RAM_writer_testbench/pac_done
add wave -noupdate /map_RAM_writer_testbench/wren
add wave -noupdate -radix unsigned /map_RAM_writer_testbench/wraddr
add wave -noupdate -radix unsigned /map_RAM_writer_testbench/dut/wrgrid
add wave -noupdate /map_RAM_writer_testbench/redata
add wave -noupdate /map_RAM_writer_testbench/wrdata
add wave -noupdate /map_RAM_writer_testbench/dut/ps
add wave -noupdate /map_RAM_writer_testbench/dut/ns
add wave -noupdate -radix unsigned /map_RAM_writer_testbench/dut/next_obj
add wave -noupdate -radix unsigned /map_RAM_writer_testbench/dut/curr_pacman
add wave -noupdate -radix unsigned /map_RAM_writer_testbench/curr_ghost1_y
add wave -noupdate -radix unsigned /map_RAM_writer_testbench/curr_ghost1_x
add wave -noupdate -radix unsigned /map_RAM_writer_testbench/next_ghost1_y
add wave -noupdate -radix unsigned /map_RAM_writer_testbench/next_ghost1_x
add wave -noupdate -radix unsigned /map_RAM_writer_testbench/curr_ghost2_y
add wave -noupdate -radix unsigned /map_RAM_writer_testbench/curr_ghost2_x
add wave -noupdate -radix unsigned /map_RAM_writer_testbench/next_ghost2_y
add wave -noupdate -radix unsigned /map_RAM_writer_testbench/next_ghost2_x
add wave -noupdate /map_RAM_writer_testbench/ghost_loc/ready
add wave -noupdate /map_RAM_writer_testbench/dut/ghost_done
add wave -noupdate /map_RAM_writer_testbench/ghost_loc/count
add wave -noupdate /map_RAM_writer_testbench/ghost_loc/ps
add wave -noupdate /map_RAM_writer_testbench/ghost_loc/ns
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {239027 ps} 0}
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
WaveRestoreZoom {0 ps} {3368033 ps}

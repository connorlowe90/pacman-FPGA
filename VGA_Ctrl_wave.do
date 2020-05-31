onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /VGA_Ctrl_testbench/CLOCK_50
add wave -noupdate /VGA_Ctrl_testbench/reset
add wave -noupdate /VGA_Ctrl_testbench/obj
add wave -noupdate /VGA_Ctrl_testbench/obj_x
add wave -noupdate /VGA_Ctrl_testbench/obj_y
add wave -noupdate /VGA_Ctrl_testbench/r
add wave -noupdate /VGA_Ctrl_testbench/g
add wave -noupdate /VGA_Ctrl_testbench/b
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {717 ps} 0}
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
WaveRestoreZoom {0 ps} {11918 ps}

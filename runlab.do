# Create work library
vlib work

# Compile Verilog
#     All Verilog files that are part of this design should have
#     their own "vlog" line below.
vlog "./VGA_Ctrl.sv"
vlog "./wall_ROM.v"
vlog "./pacman_ROM.v"
vlog "./dot_ROM.v"
vlog "./pill_ROM.v"
vlog "./ghost_r_ROM.v"
vlog "./ghost_g_ROM.v"
vlog "./ghost_b_ROM.v"

# Call vsim to invoke simulator
#     Make sure the last item on the line is the name of the
#     testbench module you want to execute.
vsim -voptargs="+acc" -t 1ps -lib work VGA_Ctrl_testbench -Lf altera_mf_ver

# Source the wave do file
#     This should be the file that sets up the signal window for
#     the module you are testing.
do VGA_Ctrl_wave.do

# Set the window types
view wave
view structure
view signals

# Run the simulation
run -all

# End

module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW,
					 CLOCK_50, VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS, PS2_DAT, PS2_CLK);
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic [3:0] KEY;
	input logic [9:0] SW;

	input CLOCK_50;
	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_BLANK_N;
	output VGA_CLK;
	output VGA_HS;
	output VGA_SYNC_N;
	output VGA_VS;
	input PS2_DAT; 
	input PS2_CLK;

	logic reset;
	logic [9:0] x;
	logic [8:0] y;
	logic [7:0] r, g, b;
	assign reset = ~KEY[0];
	assign LEDR[0] = reset;
	
	// addresses for selecting object within map
	logic [5:0] glob_x; // (0 ~ 39)
	logic [4:0] glob_y; // (0 ~ 29)
	assign glob_x = x / 16;
   assign glob_y = y / 16;
	
	// addresses for selecting pixel within object
	logic [3:0] loc_y, loc_x; // (0 ~ 15)
	assign loc_y = y % 16; 
    assign loc_x = x % 16;
	
	// selecting object encode from map ram
    logic [159:0] map_word;
    logic [3:0] map_grid;       // width of the block 
	assign map_grid = map_word[159-(4*glob_x+3)+:4]; // flip the left and right 
							// highest x  // width of the block
	// VGA control system
	map_RAM m (.address_a(glob_y), .address_b(wraddr), .clock(CLOCK_50), .data_a(), .data_b(wrdata), .wren_a(0), .wren_b(wren), .q_a(map_word), .q_b(redata)); 

	VGA_Ctrl vga_c (.CLOCK_50(CLOCK_50), .reset(reset), .obj_x(loc_x), .obj_y(loc_y), .obj(map_grid), .r(r), .g(g), .b(b));
	
	video_driver #(.WIDTH(640), .HEIGHT(480))
		v1 (.CLOCK_50(CLOCK_50), .reset(0), .x(x), .y(y), .r(r), .g(g), .b(b),
			.VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B), .VGA_BLANK_N(VGA_BLANK_N),
			.VGA_CLK(VGA_CLK), .VGA_HS(VGA_HS), .VGA_SYNC_N(VGA_SYNC_N), .VGA_VS(VGA_VS));

	logic makeBreak;
	logic [7:0] scan_code;		
	assign LEDR[1] = makeBreak;
	assign LEDR[3] = PS2_DAT;
	// PS2 keyboard control sytem
	keyboard_press_driver keyboard_driver (.CLOCK_50(CLOCK_50), .valid(), 
										   .makeBreak(makeBreak), .outCode(scan_code), 
										   .PS2_DAT(PS2_DAT),  .PS2_CLK(PS2_CLK), .reset(reset));
	keyboard_process keyboard_ctrl (.CLOCK_50(CLOCK_50), .reset(reset), 
								    .makeBreak(makeBreak), .scan_code(scan_code), 
								    .up(up), .down(down), .left(left), .right(right));
	
	logic done, up, down, left, right;
	logic [5:0] curr_pacman_x, next_pacman_x;
	logic [4:0] curr_pacman_y, next_pacman_y;
	logic [159:0] redata;
	logic wren;
	logic [4:0] wraddr;
	logic [159:0] wrdata;
	logic [3:0] collision_type;
	logic [32:0] pill_count;
	
	collision_detect collisions (.CLOCK_50(CLOCK_50), .reset(reset), .next_pacman_x(next_pacman_x),
											.next_pacman_y(next_pacman_y), .next_ghost1_x(),
											.next_ghost1_y(), .next_ghost2_x(), .next_ghost2_y(),
											.collision_type(collision_type), .pill_count(pill_count));
	
	pacman_loc_ctrl pac_loc (.CLOCK_50(CLOCK_50), .reset(reset), .done(done), 
							 .up(up), .down(down), .left(left), .right(right),
							 .curr_pacman_x(curr_pacman_x), .curr_pacman_y(curr_pacman_y), 
							 .next_pacman_x(next_pacman_x), .next_pacman_y(next_pacman_y),
							 .collision_type(collision_type), .pill_count(pill_count));
	
	map_RAM_writer map_ram_wr(.CLOCK_50(CLOCK_50), .reset(reset), 
							  .curr_pacman_x(curr_pacman_x), .curr_pacman_y(curr_pacman_y), 
							  .next_pacman_x(next_pacman_x), .next_pacman_y(next_pacman_y), 
							  .redata(redata), .wren(wren), .done(done), .wraddr(wraddr), .wrdata(wrdata));
	
	assign HEX0 = '1;
	assign HEX1 = '1;
	assign HEX2 = '1;
	assign HEX3 = '1;
	assign HEX4 = '1;
	assign HEX5 = '1;
	
endmodule

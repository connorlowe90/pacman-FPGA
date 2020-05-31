module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW,
					 CLOCK_50, VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS);
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

	logic reset;
	logic [9:0] x;
	logic [8:0] y;
	logic [7:0] r, g, b;
	assign reset = SW[0];
	assign LEDR[0] = reset;
	
	// addresses for selecting object within map
	logic [5:0] glob_x;
	logic [4:0] glob_y; 
	assign glob_x = x / 16;
   assign glob_y = y / 16;
	
	// addresses for selecting pixel within object
	logic [3:0] loc_y, loc_x;
	assign loc_y = y % 16;
   assign loc_x = x % 16;
	
	// selecting object encode from map ram
   logic [159:0] map_word;
   logic [3:0] map_grid;
	assign map_grid = map_word[159-(4*glob_x+3)+:3];
	
	
	map_RAM m (.address_a(glob_y), .address_b(), .clock(CLOCK_50), .data_a(), .data_b(), .wren_a(0), .wren_b(0), .q_a(map_word), .q_b()); 

	VGA_Ctrl vga_c (.CLOCK_50, .reset, .obj_x(loc_x), .obj_y(loc_y), .obj(map_grid), .r, .g, .b);
	
	video_driver #(.WIDTH(640), .HEIGHT(480))
		v1 (.CLOCK_50(CLOCK_50), .reset(0), .x(x), .y(y), .r(r), .g(g), .b(b),
			 .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B), .VGA_BLANK_N(VGA_BLANK_N),
			 .VGA_CLK(VGA_CLK), .VGA_HS(VGA_HS), .VGA_SYNC_N(VGA_SYNC_N), .VGA_VS(VGA_VS));
	
	assign HEX0 = '1;
	assign HEX1 = '1;
	assign HEX2 = '1;
	assign HEX3 = '1;
	assign HEX4 = '1;
	assign HEX5 = '1;
	
endmodule

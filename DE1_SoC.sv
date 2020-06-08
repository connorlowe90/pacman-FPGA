module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW,
					 CLOCK_50, VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK,
					 VGA_HS, VGA_SYNC_N, VGA_VS, PS2_DAT, PS2_CLK,
					 CLOCK2_50, 
						FPGA_I2C_SCLK, 
						FPGA_I2C_SDAT, 
						AUD_XCK, 
						AUD_DACLRCK, 
						AUD_ADCLRCK, 
						AUD_BCLK, 
						AUD_ADCDAT, 
						AUD_DACDAT);
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic [3:0] KEY;
	input logic [9:0] SW;

	input CLOCK_50, CLOCK2_50;
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
	output FPGA_I2C_SCLK;
	inout FPGA_I2C_SDAT;
	output AUD_XCK;
	input AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	input AUD_ADCDAT;
	output AUD_DACDAT;

	logic reset; // reset vga_ctrl/keyboard control/pill counter
	logic [9:0] x;
	logic [8:0] y;
	logic [7:0] r, g, b;
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
	  // PS2 keyboard control system
	    keyboard_press_driver keyboard_driver (.CLOCK_50(CLOCK_50), .valid(), 
	    									   .makeBreak(makeBreak), .outCode(scan_code), 
	    									   .PS2_DAT(PS2_DAT),  .PS2_CLK(PS2_CLK), .reset(reset));
	    keyboard_process keyboard_ctrl (.CLOCK_50(CLOCK_50), .reset(reset), 
	    							    .makeBreak(makeBreak), .scan_code(scan_code), 
	    							    .up(up), .down(down), .left(left), .right(right));


	
	logic pac_done, ghost_done, up, down, left, right;
	logic [5:0] curr_pacman_x, next_pacman_x;
	logic [4:0] curr_pacman_y, next_pacman_y;
	logic [159:0] redata, wrdata;
	logic wren;
	logic [4:0] wraddr;
	logic [32:0] pill_count;
	logic [5:0] next_ghost1_x, next_ghost2_x, curr_ghost1_x, curr_ghost2_x;
	logic [4:0] next_ghost1_y, next_ghost2_y, curr_ghost1_y, curr_ghost2_y;	

//	filter_input up_input (.CLOCK_50(CLOCK_50), .reset(reset), .in(~KEY[3]), .out(up));
//	filter_input down_input (.CLOCK_50(CLOCK_50), .reset(reset), .in(~KEY[2]), .out(down));
//	filter_input left_input (.CLOCK_50(CLOCK_50), .reset(reset), .in(~KEY[1]), .out(left));
//	filter_input right_input (.CLOCK_50(CLOCK_50), .reset(reset), .in(~KEY[0]), .out(right));
	
	
	// map that controls pacman
	logic sprit_reset;
	logic [3:0] collision_type;
	assign LEDR[7] = (pill_count > 0);
	pacman_loc_ctrl pac_loc (.CLOCK_50(CLOCK_50), .reset(sprit_reset), .done(pac_done),
							 .up(up), .down(down), .left(left), .right(right), .pill_count(pill_count), .collision_type(collision_type),
							 .curr_pacman_x(curr_pacman_x), .curr_pacman_y(curr_pacman_y), 
							 .next_pacman_x(next_pacman_x), .next_pacman_y(next_pacman_y));

	
	// module that controls ghost's location (ghost AI)
	logic ghost_enable;
	ghosts_ai2 ghost_loc (.CLOCK_50(CLOCK_50), .reset(sprit_reset), .enable(ghost_enable),
						 .curr_pacman_x(curr_pacman_x), .curr_pacman_y(curr_pacman_y), .wrdone(ghost_done), 
						 .curr_ghost1_x(curr_ghost1_x), .curr_ghost1_y(curr_ghost1_y), 
						 .curr_ghost2_x(curr_ghost2_x), .curr_ghost2_y(curr_ghost2_y),
						 .next_ghost1_x(next_ghost1_x), .next_ghost1_y(next_ghost1_y), 
						 .next_ghost2_x(next_ghost2_x), .next_ghost2_y(next_ghost2_y), 
						 .ghostCollision1(pg1_collision & pill_count > 0), .ghostCollision2(pg2_collision & pill_count > 0));


	logic map_wr_reset; 
	map_RAM_writer map_ram_wr (.CLOCK_50(CLOCK_50), .reset(map_wr_reset),
							   .curr_pacman_x(curr_pacman_x), .curr_pacman_y(curr_pacman_y), 
							   .next_pacman_x(next_pacman_x), .next_pacman_y(next_pacman_y), 
							   .curr_ghost1_x(curr_ghost1_x), .curr_ghost1_y(curr_ghost1_y), 
							   .next_ghost1_x(next_ghost1_x), .next_ghost1_y(next_ghost1_y), 
							   .curr_ghost2_x(curr_ghost2_x), .curr_ghost2_y(curr_ghost2_y),
							   .next_ghost2_x(next_ghost2_x), .next_ghost2_y(next_ghost2_y),
							   .redata(redata), .wren(wren), .pac_done(pac_done), .ghost_done(ghost_done),
							   .wraddr(wraddr), .wrdata(wrdata));

	logic start;
	logic [2:0] lives;
	assign start = SW[9];
	enum {init, game, resume ,over} ps, ns;

	// counter that counts time before resume to game state
	parameter resume_delay = 250000000; // 5 second 
	parameter resume_size = $clog2(resume_delay);
	logic resume_reset;
	logic [resume_size-1:0] resume_count;
	counter #(resume_delay) resume_counter (.CLOCK_50(CLOCK_50), .reset(resume_reset), .count(resume_count));
	
	always_comb begin
		resume_reset = 0;
		case(ps)
			init: begin
				sprit_reset = 1;
				reset = 1;
				map_wr_reset = 1;
				ghost_enable = 0;
				if (start) ns = game;
				else ns = init;
			end
			game: begin
				sprit_reset = 0;
				reset = 0;
				map_wr_reset = 0;
				ghost_enable = 1;
				if ((pg_collision) & (lives > 1) & (pill_count == 0)) begin
					ns = resume;
					resume_reset = 1;
					map_wr_reset = 1;
				end
				else if ((pg_collision) & (lives == 1) & (pill_count == 0)) ns = over;
				else ns = game;
			end
			resume: begin
				reset <= 0;
				sprit_reset = 1;
				map_wr_reset = 0;
				ghost_enable = 0;
				if (resume_count == 0) ns = game;
				else ns = resume;
			end
			over: begin
				sprit_reset = 0;
				ghost_enable = 0;
				reset = 0;
				map_wr_reset = 1;
				ns = over;
			end
		endcase
	end
	
	
	// display of number of dots eaten
	pill_counter dot_counter (.CLOCK_50(CLOCK_50), .reset(reset), .collision_type(collision_type), .hex1(HEX5), .hex2(HEX4), .hex3(HEX3));
	assign HEX1 = '1;
	assign HEX2 = '1;

	// instantiate lives hex display
	hexto7segment livesDisplay  (.in(lives), .enable(1'b1), .out(HEX0));
	
	logic game_reset;
	logic pg_collisionm, pg1_collision, pg2_collision;

	assign pg_collision = (pg1_collision | pg2_collision);
	assign pg1_collision = (next_ghost1_x == next_pacman_x) & (next_ghost1_y == next_pacman_y);
	assign pg2_collision = (next_ghost2_x == next_pacman_x) & (next_ghost2_y == next_pacman_y);
	assign game_reset = SW[0];
	
	always_ff @(posedge CLOCK_50) begin
		if (game_reset) begin
			ps <= init;
			lives <= 3'd3;
		end
		else begin
			ps <= ns;
			if (ps == game) begin
				if ((pg1_collision | pg2_collision) & (pill_count == 0)) begin
						lives <= lives - 1;	   
					end	
			end
			else lives <= lives;
		end
	end
	
	// sound controller
	logic  sound_chomp, sound_eatghost;
	assign sound_chomp = (collision_type == 4'b0010 | collision_type == 4'b0011 | pg_collision);
	
	playAudio(.chomp(sound_chomp), .eatghost(sound_eatghost),
					.reset(reset), .CLOCK_50(CLOCK_50), .CLOCK2_50(CLOCK2_50),	
						.FPGA_I2C_SCLK(FPGA_I2C_SCLK), .FPGA_I2C_SDAT(FPGA_I2C_SDAT), 
						.AUD_XCK(AUD_XCK), .AUD_DACLRCK(AUD_DACLRCK), .AUD_ADCLRCK(AUD_ADCLRCK),
						.AUD_BCLK(AUD_BCLK), .AUD_ADCDAT(AUD_ADCDAT), .AUD_DACDAT(AUD_DACDAT));

	
endmodule

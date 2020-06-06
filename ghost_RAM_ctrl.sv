// this module controls the ghost RAM by continously updating 
// the content of each location to show their proximity from 
// pacman's current location
module ghost_RAM_ctrl(CLOCK_50, reset, 
					  curr_pacman_x, curr_pacman_y,
					  curr_ghost1_x, curr_ghost1_y,
					  curr_ghost2_x, curr_ghost2_y,
					  prev_ghost1_x, prev_ghost1_y,
					  prev_ghost2_x, prev_ghost2_y,
					  rdaddr_x, rdaddr_y, data, ready);
	input logic CLOCK_50, reset;
	input logic [5:0] curr_pacman_x, curr_ghost1_x, curr_ghost2_x, prev_ghost1_x, prev_ghost2_x;
	input logic [4:0] curr_pacman_y, curr_ghost1_y, curr_ghost2_y, prev_ghost1_y, prev_ghost2_y;
	input logic [5:0] rdaddr_x;
	input logic [4:0] rdaddr_y;
	output logic [7:0] data;
	output logic ready;

	enum {comp1, comp2} ps, ns;

	// global x/y that acquires basic map info from main map
	logic [5:0] glob_x;
	logic [4:0] glob_y;
	logic [159:0] main_map_word;
	logic [3:0] main_map_grid ;
	assign main_map_grid = main_map_word[159-(4*glob_x+3)+:4];
	map_RAM main_map 
			(.address_a(glob_y), .address_b(), .clock(CLOCK_50), 
			 .data_a(), .data_b(), .wren_a(1'b0), .wren_b(1'b0), .q_a(main_map_word), .q_b()); 

	// write setup map info into the ghost_map
	logic [319:0] wr_ghost_word;
	logic [319:0] rd_ghost_word;
	logic wren;
	assign data = rd_ghost_word[319-(8*rdaddr_x+7)+:8];

	ghost_map_RAM ghost_map 
				  (.address_a(glob_y), .address_b(rdaddr_y), .clock(CLOCK_50),
				   .data_a(wr_ghost_word), .data_b(), .wren_a(wren), .wren_b(1'b0), .q_a(), .q_b(rd_ghost_word));

	// absolute difference between current pacman location and current global location
	logic [7:0] x_diff;
	logic [7:0] y_diff;
	logic [7:0] wr_ghost_grid;
	// combinational logic
	always_latch begin
		wren = 0;
		case(ps) 
		 	// a wait state that allows main_map_word/main_map_grid to update
			comp1: begin
				ns = comp2;
				
			end
			comp2: begin
				// state logic 
				ns = comp1;
				// logic that initialize the ghost map
				if (main_map_grid == 4'd1) begin
					wr_ghost_grid = 8'hFF;
					wr_ghost_word[319-(8*glob_x+7)+:8] = wr_ghost_grid; // 255
				end 
				else begin 
					if (((glob_x == curr_ghost1_x) & (glob_y == curr_ghost1_y)) | 
						((glob_x == curr_ghost2_x) & (glob_y == curr_ghost2_y))) begin
							wr_ghost_grid = 8'hFE;
							wr_ghost_word[319-(8*glob_x+7)+:8] = wr_ghost_grid; // 254
						end 
					else if (((glob_x == prev_ghost1_x) & (glob_y == prev_ghost1_y)) |
							 ((glob_x == prev_ghost2_x) & (glob_y == prev_ghost2_y))) begin
							wr_ghost_grid = 8'hFD; // 253
							wr_ghost_word[319-(8*glob_x+7)+:8] = wr_ghost_grid; 
						end
					else begin
						x_diff = (glob_x > curr_pacman_x) ? (glob_x - curr_pacman_x) : (curr_pacman_x - glob_x);
						y_diff = (glob_y > curr_pacman_y) ? (glob_y - curr_pacman_y) : (curr_pacman_y - glob_y);
						wr_ghost_grid = x_diff + y_diff;
						wr_ghost_word[319-(8*glob_x+7)+:8] = wr_ghost_grid;	
					end
				
				end 
				wren = 1;
			end
		endcase
	end


	always_ff @(posedge CLOCK_50) begin
		if (reset) begin
			ps <= comp1;
			glob_x <= 0; glob_y <= 0;
			ready <= 0;
		end
		else begin
			ps <= ns;
			ready <= ready;
			if (ps == comp2) begin
				if (glob_x == 39) begin
					glob_x <= 0;
					if (glob_y == 29) begin
						glob_y <= 0;
						ready <= 1;
					end 
					else begin
						glob_y <= glob_y + 1;
					end
				end
				else glob_x <= glob_x + 1;
			end
		end
	end

endmodule

// testbench for ghost_RAM_ctrl module
`timescale 1 ps / 1 ps
module ghost_RAM_ctrl_testbench();
	logic CLOCK_50, reset;
	logic [5:0] curr_pacman_x, curr_ghost1_x, curr_ghost2_x, prev_ghost1_x, prev_ghost2_x;
	logic [4:0] curr_pacman_y, curr_ghost1_y, curr_ghost2_y, prev_ghost1_y, prev_ghost2_y;
	logic [5:0] rdaddr_x;
	logic [4:0] rdaddr_y;
	logic [7:0] data;
	logic ready;

	ghost_RAM_ctrl dut(.*);
	parameter CLOCK_PERIOD = 100;
	initial begin
        CLOCK_50 <= 0;
        forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
    end

	initial begin
		curr_pacman_x <= 20; curr_pacman_y <= 20; reset <= 1; 
		prev_ghost1_x <= 16; prev_ghost1_y <= 13;
		prev_ghost2_x <= 23; prev_ghost2_y <= 13;
		curr_ghost1_x <= 16; curr_ghost1_y <= 13; 
		curr_ghost2_x <= 23; curr_ghost2_y <= 13; @(posedge CLOCK_50);
		reset <= 0; @(posedge CLOCK_50);
		for(int i = 0; i < 2400; i++) begin
			@(posedge CLOCK_50);
		end
		rdaddr_x <= 15; rdaddr_y <= 13; @(posedge CLOCK_50);
										@(posedge CLOCK_50);
		rdaddr_x <= 17; rdaddr_y <= 13; @(posedge CLOCK_50);
										@(posedge CLOCK_50);
		rdaddr_x <= 22; rdaddr_y <= 13; @(posedge CLOCK_50);
										@(posedge CLOCK_50);
										@(posedge CLOCK_50);
		rdaddr_x <= 21; rdaddr_y <= 14; @(posedge CLOCK_50);
										@(posedge CLOCK_50);
										@(posedge CLOCK_50);
		$stop;
	end

endmodule
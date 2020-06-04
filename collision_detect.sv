// This module detects any potential collision that may happen between 
// pacman and ghost/wall/dot/pill and return the collision type
// for collsion between dot & pill that happened, module will remove
// dot or pill from the look up map
module collision_detect
			(CLOCK_50, reset, next_pacman_x, next_pacman_y, 
			 next_ghost1_x, next_ghost1_y, next_ghost2_x, next_ghost2_y,
			 collision_type, pill_count);
	input logic CLOCK_50, reset;
	input logic [5:0] next_pacman_x, next_ghost1_x, next_ghost2_x;
	input logic [4:0] next_pacman_y, next_ghost1_y, next_ghost2_y;
	output logic [3:0] collision_type;  // 0000: no collision; 
												   // 0001: collision with wall; 
													// 0010: collision with dots; 
													// 0011: collision with pill; 
													// 0100: collision with ghost one without pill; 
													// 0101: collision with ghost two without pill;
													// 0110: collision with ghost one with pill; 
													// 0111: collision with ghost two with pill;
													// 1000: collision with ghost one with dots; 
													// 1001: collision with ghost two with dots;
	output logic [32:0] pill_count;
	
	// instantiate Map simulation
	map_simp_RAM temp (.address_a(next_pacman_y), .address_b(), .clock(CLOCK_50), .data_a(map_word2), 
					.data_b(), .wren_a(wren), .wren_b(), .q_a(map_word), .q_b()); 
	
	logic [3:0] obj;       // width of the block 
	logic wren;
	logic [159:0] map_word2, map_word;
	logic [32:0] next_pill_count;
	
	enum {hold, compute_collision} ps, ns;
	
	assign obj = map_word[159-(4*next_pacman_x+3)+:4]; // flip the left and right 
	
	always_comb begin
		// defaults
		wren = 0; 
	   collision_type = 3'b000;
		next_pill_count = 0; map_word2 = map_word;
		case(ps)
			hold: begin
				 ns = compute_collision;
			end
			compute_collision: begin
				if (reset) begin
						collision_type = 3'b000;
						next_pill_count = 0;
				  end 
				  else begin
						if (obj == 4'h1) begin // collision with wall
							 collision_type = 4'b0001;
						end
						else if(obj == 4'h2) begin // collision with dots
							collision_type = 4'b0010;
							wren = 1;
							map_word2[159-(4*next_pacman_x+3)+:4] = 0;
						end
						else if (obj == 4'h3) begin // collision with pill
							collision_type = 4'b0011;
							next_pill_count = pill_count + 1500000000; // Each pill adds 30 seconds of effective time
							wren = 1;
							map_word2[159-(4*next_pacman_x+3)+:4] = 0;
						end
						else if (obj == 4'h5) begin // collision with ghosts
							if ((next_pacman_x == next_ghost1_x) & (next_pacman_y == next_ghost1_y)) begin
								collision_type = 4'b0100;
							end
							else if ((next_pacman_x == next_ghost2_x) & (next_pacman_y == next_ghost2_y)) begin
								collision_type = 4'b0101;
							end
						end
						else if(obj == 4'h7) begin // collision with ghosts and pill (pill is eaten before ghost arrives)
							if ((next_pacman_x == next_ghost1_x) & (next_pacman_y == next_ghost1_y)) begin
								collision_type = 4'b0110;
								next_pill_count = pill_count + 1500000000; // Each pill adds 30 seconds of effective time
								wren = 1;
								map_word2[159-(4*next_pacman_x+3)+:4] = 0;
							end
							else if ((next_pacman_x == next_ghost2_x) & (next_pacman_y == next_ghost2_y)) begin
								collision_type = 4'b0111;
								next_pill_count = pill_count + 1500000000; // Each pill adds 30 seconds of effective time
								wren = 1;
								map_word2[159-(4*next_pacman_x+3)+:4] = 0;
							end
						end
						else if(obj == 4'h6) begin // collision with ghosts and dots (dots eaten before ghost arrives)
							if ((next_pacman_x == next_ghost1_x) & (next_pacman_y == next_ghost1_y)) begin
								collision_type = 4'b0100;
								wren = 1;
								map_word2[159-(4*next_pacman_x+3)+:4] = 0;
							end
							else if ((next_pacman_x == next_ghost2_x) & (next_pacman_y == next_ghost2_y)) begin
								collision_type = 4'b0101;
								wren = 1;
								map_word2[159-(4*next_pacman_x+3)+:4] = 0;
							end
						end
						else begin
							 ;
						end 
				  end
				  ns = hold;
				end
		endcase 
	end
	
	always_ff @(posedge CLOCK_50) begin
		if (reset) begin
			pill_count <= 0;
			ps <= hold;
		end
		else begin
		   if (pill_count != 0) pill_count <= next_pill_count - 1;
			ps <= ns;
		end
	end
	
endmodule

//0 - empty
//1 - wall
//2 - dots
//3 - pills
//4 - pacman
//5 - ghost
//6 - ghost + dots
//7 - ghost + pills
//	

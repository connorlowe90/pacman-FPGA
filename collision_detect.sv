// Connor Lowe
// Winston Chen
// 1573616
// 5/3/2020
// EE 371
// Lab 6
//
// This module detects any potential collision that may happen between 
// pacman and ghost/wall/dot/pill and return the collision type
// for collsion between dot & pill that happened, module will remove
// dot or pill from the look up map
module collision_detect
			(CLOCK_50, reset, colli_clr, next_pacman_x, next_pacman_y, 
			 collision_type, pill_count);
	input logic CLOCK_50, reset, colli_clr;
	input logic [5:0] next_pacman_x;
	input logic [4:0] next_pacman_y;
	output logic [3:0] collision_type;  // 0000: no collision; 
													// 0001: collision with wall; 
													// 0010: collision with dots; 
													// 0011: collision with pill; 
	output logic [32:0] pill_count;
	
	logic [3:0] obj;       // width of the block 
	logic wren;
	logic [159:0] map_word2, map_word;
	logic [4:0] reset_addr;
	logic [159:0] reset_word;
	logic reset_wren;
	logic pill_incr;
	enum {reset_mem, reset_hold, hold, compute_collision} ps, ns;
	assign reset_wren = (ps == reset_hold);
	
	// instantiate Map simulation
	// current state ram
	map_simp_RAM temp (.address_a(next_pacman_y), .address_b(reset_addr), .clock(CLOCK_50), .data_a(map_word2), 
					.data_b(reset_word), .wren_a(wren), .wren_b(reset_wren), .q_a(map_word), .q_b()); 	
	// reset ram
	map_simp_RAM reset_ram (.address_a(reset_addr), .address_b(), .clock(CLOCK_50), .data_a(), 
					   .data_b(), .wren_a(0), .wren_b(0), .q_a(reset_word), .q_b()); 	
	
	
	assign obj = map_word[159-(4*next_pacman_x+3)+:4]; // flip the left and right 
	
	// latched block determing the collision type based on pacmans next location.
	always_latch begin
		// defaults
		wren = 0; 
		map_word2 = map_word;
		pill_incr = 0;
		case(ps)
			reset_mem: begin
				ns = reset_hold;
			end // closes reset_mem state
			reset_hold: begin
				if (reset_addr == 5'd29) ns = hold;
				else ns = reset_mem;
			end // closes reset_hold state
			hold: begin
				 ns = compute_collision;
			end // closes hold state
			compute_collision: begin
				if (reset | colli_clr) begin
						collision_type = 3'b000;
						wren = 0;
				  end 
				  else begin
					  	if (obj == 4'h0) begin
							collision_type = 4'b0000;
						  	wren = 0;
						end
						else if (obj == 4'h1) begin // collision with wall
							 collision_type = 4'b0001;
							 wren = 0;
						end
						else if(obj == 4'h2) begin // collision with dots
							collision_type = 4'b0010;
							wren = 1;
							map_word2[159-(4*next_pacman_x+3)+:4] = 0;
						end
						else if (obj == 4'h3) begin // collision with pill
							collision_type = 4'b0011;
							pill_incr = 1;
							wren = 1;
							map_word2[159-(4*next_pacman_x+3)+:4] = 0;
						end
				  end
				  ns = hold;
				end // closes compute_collision state
		endcase 
	end // always_latch
	
	// sequential logic block determing pill count
	always_ff @(posedge CLOCK_50) begin
		if (reset) begin
			pill_count <= 0;
			ps <= reset_mem;
			reset_addr <= 5'd0;
		end
		else begin
			ps <= ns;
			if (ps == reset_hold) reset_addr <= reset_addr + 1;
		    if (pill_incr) pill_count <= pill_count + 1500000000;
			else if (pill_count > 0) pill_count <= pill_count - 1;
			else pill_count <= pill_count;
		end
	end // always_ff
	
endmodule // closes collision detection module

module collision_detect_testbench();
	logic CLOCK_50, reset, colli_clr;
	logic [5:0] next_pacman_x;
	logic [4:0] next_pacman_y;
	logic [3:0] collision_type;  // 0000: no collision; 
													// 0001: collision with wall; 
													// 0010: collision with dots; 
													// 0011: collision with pill; 
	logic [32:0] pill_count;

	// utilizing verilog's implicit port connections
	collision_detect dut (.*);
	
	// block that sets up the clock
	parameter CLOCK_PERIOD = 100;
    initial begin
        CLOCK_50 <= 0;
        forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
    end

	 // block that sets inputs for design
    initial begin
        reset = 1;         	  @(posedge CLOCK_50);
		  reset = 0;			 	  @(posedge CLOCK_50);
		  next_pacman_x = 5'd20;
	     next_pacman_y = 5'd21;  @(posedge CLOCK_50);
		  next_pacman_x = 5'd21;
	     next_pacman_y = 5'd20;  @(posedge CLOCK_50);
		$stop;
    end // closes block setting inputs to design
endmodule // closes module testing pacman location control
// This module helps ghosts find their smartest path to reach pacman given 
// pacman's current location and ghost's current location
module ghosts_loc_ctrl #(parameter DELAY= 30000000)
		 (CLOCK_50, reset, enable, curr_pacman_x, curr_pacman_y, collision_type, pill_count,
		  wrdone, curr_ghost1_x, curr_ghost1_y, curr_ghost2_x, curr_ghost2_y,
		  next_ghost1_x, next_ghost1_y, next_ghost2_x, next_ghost2_y);

	input logic CLOCK_50, reset, enable; // enable signal use to activate/deactivate the movement of ghost
	input logic [1:0] collision_type; 
	input logic [32:0] pill_count; // current energy pill left
	input logic wrdone;
	input logic [5:0] curr_pacman_x;
	input logic [4:0] curr_pacman_y;
	output logic [5:0] next_ghost1_x, next_ghost2_x;
	output logic [4:0] next_ghost1_y, next_ghost2_y;
	output logic [5:0] curr_ghost1_x, curr_ghost2_x;
	output logic [4:0] curr_ghost1_y, curr_ghost2_y;

	logic [5:0] prev_ghost1_x, prev_ghost2_x;
	logic [4:0] prev_ghost1_y, prev_ghost2_y;

	// possible next step options
	logic [5:0] next_ghost1_x1, next_ghost1_x2, next_ghost1_x3, next_ghost1_x4,
				next_ghost2_x1, next_ghost2_x2, next_ghost2_x3, next_ghost2_x4;
	logic [4:0] next_ghost1_y1, next_ghost1_y2, next_ghost1_y3, next_ghost1_y4,
				next_ghost2_y1, next_ghost2_y2, next_ghost2_y3, next_ghost2_y4;
	// up one step
	assign next_ghost1_x1 = curr_ghost1_x;
	assign next_ghost1_y1 = curr_ghost1_y - 1;
	assign next_ghost2_x1 = curr_ghost2_x;
	assign next_ghost2_y1 = curr_ghost2_y - 1;
	// down one step
	assign next_ghost1_x2 = curr_ghost1_x;
	assign next_ghost1_y2 = curr_ghost1_y + 1;
	assign next_ghost2_x2 = curr_ghost2_x;
	assign next_ghost2_y2 = curr_ghost2_y + 1; 
	// left one step
	assign next_ghost1_x3 = curr_ghost1_x - 1;
	assign next_ghost1_y3 = curr_ghost1_y;
	assign next_ghost2_x3 = curr_ghost2_x - 1;
	assign next_ghost2_y3 = curr_ghost2_y;
	// right one step
	assign next_ghost1_x4 = curr_ghost1_x + 1;
	assign next_ghost1_y4 = curr_ghost1_y;
	assign next_ghost2_x4 = curr_ghost2_x + 1;
	assign next_ghost2_y4 = curr_ghost2_y;

	enum {init, check1_1, check1_2, check1_3, check1_4,
		  check2_1, check2_2, check2_3, check2_4, done, wait_init} ps, ns;
	// counter system
	parameter MAX = DELAY; // 50M reduce the ghost speed to 1Hz 
	parameter size = $clog2(MAX);
	logic [size-1:0] count;
	logic clk_reset;
	counter #(MAX) c (.CLOCK_50(CLOCK_50), .reset(clk_reset), .count(count));
	assign clk_reset = (ps == init);

	// ghost map ram that keep track of each grid's proximity from pacman
	logic [5:0] rdaddr_x;
	logic [4:0] rdaddr_y;
	logic [7:0] data;
	logic ready;
	ghost_RAM_ctrl ghost_ram (.CLOCK_50(CLOCK_50), .reset(reset), 
					  		  .curr_pacman_x(curr_pacman_x), .curr_pacman_y(curr_pacman_y),
					  		  .curr_ghost1_x(curr_ghost1_x), .curr_ghost1_y(curr_ghost1_y),
					  		  .curr_ghost2_x(curr_ghost2_x), .curr_ghost2_y(curr_ghost2_y),
					  		  .prev_ghost1_x(prev_ghost1_x), .prev_ghost1_y(prev_ghost1_y),
					  		  .prev_ghost2_x(prev_ghost2_x), .prev_ghost2_y(prev_ghost2_y),
					  		  .rdaddr_x(rdaddr_x), .rdaddr_y(rdaddr_y), .data(data), .ready(ready));

	// get value from each possible steps and compare
	// logic [7:0] next_ghost1_val1, next_ghost1_val2, next_ghost1_val3, next_ghost1_val4, 
	// 			next_ghost2_val1, next_ghost2_val2, next_ghost2_val3, next_ghost2_val4;
	logic [5:0] next_ghost1_min_x, next_ghost2_min_x;
	logic [4:0] next_ghost1_min_y, next_ghost2_min_y;
	logic [7:0] next_ghost1_min_val, next_ghost2_min_val;
	always_latch begin
		case(ps) 
			init: begin
				if (ready & enable) begin
					ns = check1_1;
				end
				else ns = init;
				// rdaddr_x = next_ghost1_x1;
				rdaddr_x = next_ghost1_x1;
				rdaddr_y = next_ghost1_y1;
				next_ghost1_min_x = curr_ghost1_x;
				next_ghost1_min_y = curr_ghost1_y;
				next_ghost1_min_val = 254;
				next_ghost2_min_x = curr_ghost2_x;
				next_ghost2_min_y = curr_ghost2_y;
				next_ghost2_min_val = 254;
			end
			check1_1: begin // check up 
				ns = check1_2;
				// next_ghost1_val1 = data;
				rdaddr_x = next_ghost1_x1;
				rdaddr_y = next_ghost1_y2;
				if (data < next_ghost1_min_val) begin
					next_ghost1_min_x = next_ghost1_x1;
					next_ghost1_min_y = next_ghost1_y1;
					next_ghost1_min_val = data;
				end
			end
			check1_2: begin // check down (change y from previous state)
				ns = check1_3;
				// next_ghost1_val2 = data;
				rdaddr_x = next_ghost1_x2;
				rdaddr_y = next_ghost1_y3;
				if (data < next_ghost1_min_val) begin
					next_ghost1_min_x = next_ghost1_x2;
					next_ghost1_min_y = next_ghost1_y2;
					next_ghost1_min_val = data;
				end
			end
			check1_3: begin // check left (change y from previous state)
				ns = check1_4;
				// next_ghost1_val3 = data;
				rdaddr_x = next_ghost1_x3;
				rdaddr_y = next_ghost1_y4;
				if (data < next_ghost1_min_val) begin
					next_ghost1_min_x = next_ghost1_x3;
					next_ghost1_min_y = next_ghost1_y3;
					next_ghost1_min_val = data;
				end
			end
			check1_4: begin // check right (does not change y from previous state)
				ns = check2_1; 
				// next_ghost1_val4 = data;
				rdaddr_x = next_ghost1_x4;
				rdaddr_y = next_ghost2_y1;
				if (data < next_ghost1_min_val) begin
					next_ghost1_min_x = next_ghost1_x4;
					next_ghost1_min_y = next_ghost1_y4;
					next_ghost1_min_val = data;
				end
			end
			check2_1: begin // check up (change y from previous state)
				ns = check2_2;
				// next_ghost2_val1 = data;
				rdaddr_x = next_ghost2_x1;
				rdaddr_y = next_ghost2_y2;
				if (data < next_ghost2_min_val) begin
					next_ghost2_min_x = next_ghost2_x1;
					next_ghost2_min_y = next_ghost2_y1;
					next_ghost2_min_val = data;
				end
			end
			check2_2: begin // check down (change y from previous state)
				ns = check2_3; 
				// next_ghost2_val2 = data;
				rdaddr_x = next_ghost2_x2;
				rdaddr_y = next_ghost2_y3;
				if (data < next_ghost2_min_val) begin
					next_ghost2_min_x = next_ghost2_x2;
					next_ghost2_min_y = next_ghost2_y2;
					next_ghost2_min_val = data;
				end
			end
			check2_3: begin // check left (change y from previous state)
				ns = check2_4; 
				// next_ghost2_val3 = data;
				rdaddr_x = next_ghost2_x3;
				rdaddr_y = next_ghost2_y4;
				if (data < next_ghost2_min_val) begin
					next_ghost2_min_x = next_ghost2_x3;
					next_ghost2_min_y = next_ghost2_y3;
					next_ghost2_min_val = data;
				end
			end
			check2_4: begin // check right (doesn't change y from previous state)
				ns = done;
				// next_ghost2_val4 = data;
				rdaddr_x = next_ghost2_x4;
				rdaddr_y = next_ghost2_y4;
				if (data < next_ghost2_min_val) begin
					next_ghost2_min_x = next_ghost2_x4;
					next_ghost2_min_y = next_ghost2_y4;
					next_ghost2_min_val = data;
				end
			end
			// done: begin
			// 	ns = wait_init;
			// 	// logic that decides ghost1's next step
			// 	if ((next_ghost1_val1 < next_ghost1_val2) & 
			// 		(next_ghost1_val1 < next_ghost1_val3) & 
			// 		(next_ghost1_val1 < next_ghost1_val4)) begin
			// 			next_ghost1_min_x = next_ghost1_x1;
			// 			next_ghost1_min_y = next_ghost1_y1;
			// 		end
			// 	else if ((next_ghost1_val2 < next_ghost1_val1) & 
			// 			 (next_ghost1_val2 < next_ghost1_val3) & 
			// 			 (next_ghost1_val2 < next_ghost1_val4)) begin
			// 				next_ghost1_min_x = next_ghost1_x2;
			// 				next_ghost1_min_y = next_ghost1_y2;
			// 			end
			// 	else if ((next_ghost1_val3 < next_ghost1_val1) & 
			// 			 (next_ghost1_val3 < next_ghost1_val2) & 
			// 			 (next_ghost1_val3 < next_ghost1_val4)) begin
			// 				next_ghost1_min_x = next_ghost1_x3;
			// 				next_ghost1_min_y = next_ghost1_y3;
			// 			end
			// 	else if ((next_ghost1_val4 < next_ghost1_val1) & 
			// 			 (next_ghost1_val4 < next_ghost1_val2) & 
			// 			 (next_ghost1_val4 < next_ghost1_val3)) begin
			// 				next_ghost1_min_x = next_ghost1_x4;
			// 				next_ghost1_min_y = next_ghost1_y4;
			// 			end
			// 	// logic that decides ghost2's next step
			// 	if ((next_ghost2_val1 < next_ghost2_val2) & 
			// 		 (next_ghost2_val1 < next_ghost2_val3) & 
			// 	    (next_ghost2_val1 < next_ghost2_val4)) begin
			// 			next_ghost2_min_x = next_ghost2_x1;
			// 			next_ghost2_min_y = next_ghost2_y1;
			// 		end
			// 	else if ((next_ghost2_val2 < next_ghost2_val1) & 
			// 			   (next_ghost2_val2 < next_ghost2_val3) & 
			// 			   (next_ghost2_val2 < next_ghost2_val4)) begin
			// 			 	next_ghost2_min_x = next_ghost2_x2;
			// 				next_ghost2_min_y = next_ghost2_y2;
			// 			end
			// 	else if ((next_ghost2_val3 < next_ghost2_val1) & 
			// 			 (next_ghost2_val3 < next_ghost2_val2) & 
			// 			 (next_ghost2_val3 < next_ghost2_val4)) begin
			// 				next_ghost2_min_x = next_ghost2_x3;
			// 				next_ghost2_min_y = next_ghost2_y3;
			// 			end
			// 	else if ((next_ghost2_val4 < next_ghost2_val1) & 
			// 			 (next_ghost2_val4 < next_ghost2_val2) & 
			// 			 (next_ghost2_val4 < next_ghost2_val3)) begin
			// 				next_ghost2_min_x = next_ghost2_x4;
			// 				next_ghost2_min_y = next_ghost2_y4;
			// 			end
			// end
			 done: begin
				if (count == 0) ns = init;
				else ns = done;
			end
		endcase
	end



	always_ff @(posedge CLOCK_50) begin
		if (reset) begin
			ps <= init;
			prev_ghost1_x <= 6'd16;
			prev_ghost1_y <= 5'd13;
			prev_ghost2_x <= 6'd23;
			prev_ghost2_y <= 5'd13;

			curr_ghost1_x <= 6'd16;
			curr_ghost1_y <= 5'd13;
			curr_ghost2_x <= 6'd23;
			curr_ghost2_y <= 5'd13;


			next_ghost1_x <= 6'd16;
			next_ghost1_y <= 5'd13;
			next_ghost2_x <= 6'd23;
			next_ghost2_y <= 5'd13;
		end
		else begin
			ps <= ns;
			if (ps == done) begin
				next_ghost1_x <= next_ghost1_min_x;
				next_ghost1_y <= next_ghost1_min_y;
				next_ghost2_x <= next_ghost2_min_x;
				next_ghost2_y <= next_ghost2_min_y;
			end
			if (wrdone) begin 
				curr_ghost1_x <= next_ghost1_x;
				curr_ghost1_y <= next_ghost1_y;
				curr_ghost2_x <= next_ghost2_x;
				curr_ghost2_y <= next_ghost2_y;
				prev_ghost1_x <= curr_ghost1_x;
				prev_ghost1_y <= curr_ghost1_y;
				prev_ghost2_x <= curr_ghost2_x;
				prev_ghost2_y <= curr_ghost2_y;
			end
			else begin
				curr_ghost1_x <= curr_ghost1_x;
				curr_ghost1_y <= curr_ghost1_y;
				curr_ghost2_x <= curr_ghost2_x;
				curr_ghost2_y <= curr_ghost2_y;
				prev_ghost1_x <= prev_ghost1_x; 
				prev_ghost1_y <= prev_ghost1_y;
				prev_ghost2_x <= prev_ghost2_x;
				prev_ghost2_y <= prev_ghost2_y;
			end
		end
	end

	
endmodule


// testbench for ghost_loc_ctrl
`timescale 1 ps / 1 ps
module ghosts_loc_ctrl_testbench();
	logic CLOCK_50, reset;
	logic [1:0] collision_type; 
	logic [32:0] pill_count; // current energy pill left
	logic wrdone, enable;
	logic [5:0] curr_pacman_x;
	logic [4:0] curr_pacman_y;
	logic [5:0] next_ghost1_x, next_ghost2_x;
	logic [4:0] next_ghost1_y, next_ghost2_y;
	logic [5:0] curr_ghost1_x, curr_ghost2_x;
	logic [4:0] curr_ghost1_y, curr_ghost2_y;

	parameter DELAY = 2413;
	ghosts_loc_ctrl #(DELAY) dut (.*);
	parameter CLOCK_PERIOD = 100;
	initial begin
        CLOCK_50 <= 0;
        forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
    end

	initial begin
		reset <= 1; enable <= 1; @(posedge CLOCK_50);
		curr_pacman_x <= 20; curr_pacman_y <= 20; reset <= 0; @(posedge CLOCK_50);
		for (int i = 0; i < 2400; i ++) begin
			@(posedge CLOCK_50);
		end
		for (int i = 0; i < 11; i ++) begin
			@(posedge CLOCK_50);
		end
		wrdone <= 1; @(posedge CLOCK_50);
		wrdone <= 0; @(posedge CLOCK_50);
		for (int i = 0; i < 2400; i ++) begin
			@(posedge CLOCK_50);
		end
		for (int i = 0; i < 11; i ++) begin
			@(posedge CLOCK_50);
		end
		wrdone <= 1; @(posedge CLOCK_50);
		wrdone <= 0; @(posedge CLOCK_50);
		for (int i = 0; i < 2400; i ++) begin
			@(posedge CLOCK_50);
		end
		wrdone <= 1; @(posedge CLOCK_50);
		wrdone <= 0; @(posedge CLOCK_50);
		for (int i = 0; i < 2400; i ++) begin
			@(posedge CLOCK_50);
		end
		wrdone <= 1; @(posedge CLOCK_50);
		wrdone <= 0; @(posedge CLOCK_50);
		for (int i = 0; i < 2400; i ++) begin
			@(posedge CLOCK_50);
		end
		wrdone <= 1; @(posedge CLOCK_50);
		wrdone <= 0; @(posedge CLOCK_50);
		for (int i = 0; i < 2400; i ++) begin
			@(posedge CLOCK_50);
		end
		wrdone <= 1; @(posedge CLOCK_50);
		wrdone <= 0; @(posedge CLOCK_50);
		for (int i = 0; i < 2400; i ++) begin
			@(posedge CLOCK_50);
		end
		wrdone <= 1; @(posedge CLOCK_50);
		wrdone <= 0; @(posedge CLOCK_50);
		$stop;
	end
endmodule

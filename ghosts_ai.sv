// This module helps ghosts find their smartest path to reach pacman given 
// pacman's current location and ghost's current location
module ghosts_ai #(parameter DELAY= 50000000)
		 (CLOCK_50, reset, enable, curr_pacman_x, curr_pacman_y,
		  wrdone, curr_ghost1_x, curr_ghost1_y, curr_ghost2_x, curr_ghost2_y,
		  next_ghost1_x, next_ghost1_y, next_ghost2_x, next_ghost2_y, ghostCollision1, ghostCollision2);

	input logic CLOCK_50, reset, enable; // enable signal use to activate/deactivate the movement of ghost
	input logic wrdone, ghostCollision1, ghostCollision2;
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

	enum {init, check1_1_hold1, check1_1_hold2, check1_1, check1_2_hold1, check1_2_hold2, check1_2,
          check1_3_hold1, check1_3_hold2, check1_3, check1_4_hold1, check1_4_hold2, check1_4,
          check2_1_hold1, check2_1_hold2, check2_1, check2_2_hold1, check2_2_hold2, check2_2, 
          check2_3_hold1, check2_3_hold2, check2_3, check2_4_hold1, check2_4_hold2, check2_4, done} ps, ns;

	// counter system
	parameter MAX = DELAY; // 50M reduce the ghost speed to 1Hz 
	parameter size = $clog2(MAX);
	logic [size-1:0] count;
	logic clk_reset;
	counter #(MAX) c (.CLOCK_50(CLOCK_50), .reset(clk_reset), .count(count));
	assign clk_reset = (ps == init);
	
	parameter MAX2 = 100000000; // 50M reduce the ghost speed to 1Hz 
	parameter size2 = $clog2(MAX2);
	logic [size2-1:0] count2;
	logic [size2-1:0] count3;
	logic clk2_reset;
	counter #(MAX2) c2 (.CLOCK_50(CLOCK_50), .reset(ghostCollision1), .count(count2));
	counter #(MAX2) c3 (.CLOCK_50(CLOCK_50), .reset(ghostCollision2), .count(count3));

	// global x/y that acquires basic map info from main map
	logic [5:0] rdaddr_x;
	logic [4:0] rdaddr_y;
	logic [159:0] main_map_reg1, main_map_reg2, main_map_out;
	logic [3:0] main_map_grid;
	assign main_map_grid = main_map_reg2[159-(4*rdaddr_x+3)+:4];
	map_RAM main_map 
			(.address_a(rdaddr_y), .address_b(), .clock(CLOCK_50), 
			 .data_a(), .data_b(), .wren_a(1'b0), .wren_b(1'b0), .q_a(main_map_out), .q_b()); 

	// get value from each possible steps and compare
	// logic [7:0] next_ghost1_val1, next_ghost1_val2, next_ghost1_val3, next_ghost1_val4, 
	// 			next_ghost2_val1, next_ghost2_val2, next_ghost2_val3, next_ghost2_val4;
	logic [5:0] next_ghost1_min_x, next_ghost2_min_x;
	logic [4:0] next_ghost1_min_y, next_ghost2_min_y;
	logic [7:0] next_ghost1_min_val, next_ghost2_min_val;
    logic [7:0] x_diff, y_diff;

	always_latch begin
		case(ps) 
			init: begin
				if (enable) begin
					ns = check1_1_hold1;
				end
				else ns = init;
				rdaddr_x = next_ghost1_x1;
				rdaddr_y = next_ghost1_y1;
                x_diff = (curr_ghost1_x > curr_pacman_x) ? (curr_ghost1_x - curr_pacman_x) : (curr_pacman_x - curr_ghost1_x);
				y_diff = (curr_ghost1_y > curr_pacman_y) ? (curr_ghost1_y - curr_pacman_y) : (curr_pacman_y - curr_ghost1_y);
				next_ghost1_min_val = 8'd255;
                next_ghost1_min_x = curr_ghost1_x;
                next_ghost1_min_y = curr_ghost1_y;
                x_diff = (curr_ghost2_x > curr_pacman_x) ? (curr_ghost2_x - curr_pacman_x) : (curr_pacman_x - curr_ghost2_x);
				y_diff = (curr_ghost2_y > curr_pacman_y) ? (curr_ghost2_y - curr_pacman_y) : (curr_pacman_y - curr_ghost2_y);
				next_ghost2_min_val = 8'd255;
                next_ghost2_min_x = curr_ghost2_x;
                next_ghost2_min_y = curr_ghost2_y;
			end
            check1_1_hold1: begin
                ns = check1_1_hold2;
                rdaddr_x = next_ghost1_x1;
				rdaddr_y = next_ghost1_y1;
            end
            check1_1_hold2: begin
                ns = check1_1;
                rdaddr_x = next_ghost1_x1;
				rdaddr_y = next_ghost1_y1;
            end
			check1_1: begin // check up 
				ns = check1_2_hold1;
				x_diff = (next_ghost1_x1 > curr_pacman_x) ? (next_ghost1_x1 - curr_pacman_x) : (curr_pacman_x - next_ghost1_x1);
				y_diff = (next_ghost1_y1 > curr_pacman_y) ? (next_ghost1_y1 - curr_pacman_y) : (curr_pacman_y - next_ghost1_y1);
				rdaddr_x = next_ghost1_x1;
				rdaddr_y = next_ghost1_y2;
				if (main_map_grid != 4'd1) begin // 1 next does not overlap with wall
                    if ((next_ghost1_x1 != curr_ghost2_x) | (next_ghost1_y1 != curr_ghost2_y)) begin // 1 next doesn't overlap with 2 curr
                        if ((next_ghost1_x1 != prev_ghost1_x) | (next_ghost1_y1 != prev_ghost1_y)) begin // 1 next doesn't overlap with 1 prev
                           if ((x_diff + y_diff) < next_ghost1_min_val) begin
                               next_ghost1_min_val = x_diff + y_diff;
                               next_ghost1_min_x = next_ghost1_x1;
                               next_ghost1_min_y = next_ghost1_y1;
                           end 
                        end
                    end
				end
			end
            check1_2_hold1: begin
                ns = check1_2_hold2;
                rdaddr_x = next_ghost1_x2;
				rdaddr_y = next_ghost1_y2;
            end
            check1_2_hold2: begin
                ns = check1_2;
                rdaddr_x = next_ghost1_x2;
				rdaddr_y = next_ghost1_y2;
            end
			check1_2: begin // check down (change y from previous state)
				ns = check1_3_hold1;
				x_diff = (next_ghost1_x2 > curr_pacman_x) ? (next_ghost1_x2 - curr_pacman_x) : (curr_pacman_x - next_ghost1_x2);
				y_diff = (next_ghost1_y2 > curr_pacman_y) ? (next_ghost1_y2 - curr_pacman_y) : (curr_pacman_y - next_ghost1_y2);
                // $display("main_map_grid = %d, %t", main_map_grid, $time());
				rdaddr_x = next_ghost1_x2;
				rdaddr_y = next_ghost1_y3;
				if (main_map_grid != 4'd1) begin // 1 next does not overlap with wall
					if ((next_ghost1_x2 != curr_ghost2_x) | (next_ghost1_y2 != curr_ghost2_y)) begin // 1 next doesn't overlap with 2 curr
						if ((next_ghost1_x2 != prev_ghost1_x) | (next_ghost1_y2 != prev_ghost1_y)) begin // 1 next doesn't overlap with 1 prev
							if ((x_diff + y_diff) < next_ghost1_min_val) begin
                                next_ghost1_min_val = x_diff + y_diff;
                                next_ghost1_min_x = next_ghost1_x2;
                                next_ghost1_min_y = next_ghost1_y2;
							end 
                        end
                    end
				end
			end
            check1_3_hold1: begin
                ns = check1_3_hold2;
                rdaddr_x = next_ghost1_x3;
				rdaddr_y = next_ghost1_y3;
            end
            check1_3_hold2: begin
                ns = check1_3;
                rdaddr_x = next_ghost1_x3;
				rdaddr_y = next_ghost1_y3;
            end
			check1_3: begin // check left (change y from previous state)
				ns = check1_4_hold1;
				x_diff = (next_ghost1_x3 > curr_pacman_x) ? (next_ghost1_x3 - curr_pacman_x) : (curr_pacman_x - next_ghost1_x3);
				y_diff = (next_ghost1_y3 > curr_pacman_y) ? (next_ghost1_y3 - curr_pacman_y) : (curr_pacman_y - next_ghost1_y3);
				rdaddr_x = next_ghost1_x3;
				rdaddr_y = next_ghost1_y4;
				if (main_map_grid != 4'd1) begin // 1 next does not overlap with wall
                    if ((next_ghost1_x3 != curr_ghost2_x) | (next_ghost1_y3 != curr_ghost2_y)) begin // 1 next doesn't overlap with 2 curr
                        if ((next_ghost1_x3 != prev_ghost1_x) | (next_ghost1_y3 != prev_ghost1_y)) begin // 1 next doesn't overlap with 1 prev
                           if ((x_diff + y_diff) < next_ghost1_min_val) begin
                               next_ghost1_min_val = x_diff + y_diff;
                               next_ghost1_min_x = next_ghost1_x3;
                               next_ghost1_min_y = next_ghost1_y3;
                           end 
                        end
                    end
				end
			end
            check1_4_hold1: begin
                ns = check1_4_hold2;
                rdaddr_x = next_ghost1_x4;
				rdaddr_y = next_ghost1_y4;
            end
            check1_4_hold2: begin
                ns = check1_4;
                rdaddr_x = next_ghost1_x4;
				rdaddr_y = next_ghost1_y4;
            end
			check1_4: begin // check right (does not change y from previous state)
				ns = check2_1_hold1; 
				x_diff = (next_ghost1_x4 > curr_pacman_x) ? (next_ghost1_x4 - curr_pacman_x) : (curr_pacman_x - next_ghost1_x4);
				y_diff = (next_ghost1_y4 > curr_pacman_y) ? (next_ghost1_y4 - curr_pacman_y) : (curr_pacman_y - next_ghost1_y4);
				rdaddr_x = next_ghost1_x4;
				rdaddr_y = next_ghost2_y1;
				if (main_map_grid != 4'd1) begin // 1 next does not overlap with wall
                    if ((next_ghost1_x4 != curr_ghost2_x) | (next_ghost1_y4 != curr_ghost2_y)) begin // 1 next doesn't overlap with 2 curr
                        if ((next_ghost1_x4 != prev_ghost1_x) | (next_ghost1_y4 != prev_ghost1_y)) begin // 1 next doesn't overlap with 1 prev
                           if ((x_diff + y_diff) < next_ghost1_min_val) begin
                               next_ghost1_min_val = x_diff + y_diff;
                               next_ghost1_min_x = next_ghost1_x4;
                               next_ghost1_min_y = next_ghost1_y4;
                           end 
                        end
                    end
				end
			end
            check2_1_hold1: begin
                ns = check2_1_hold2;
                rdaddr_x = next_ghost2_x1;
				rdaddr_y = next_ghost2_y1;
            end
            check2_1_hold2: begin
                ns = check2_1;
                rdaddr_x = next_ghost2_x1;
				rdaddr_y = next_ghost2_x1;
            end
			check2_1: begin // check up (change y from previous state)
				ns = check2_2_hold1;
				x_diff = (next_ghost2_x1 > curr_pacman_x) ? (next_ghost2_x1 - curr_pacman_x) : (curr_pacman_x - next_ghost2_x1);
				y_diff = (next_ghost2_y1 > curr_pacman_y) ? (next_ghost2_y1 - curr_pacman_y) : (curr_pacman_y - next_ghost2_y1);
				rdaddr_x = next_ghost2_x1;
				rdaddr_y = next_ghost2_y2;
				if (main_map_grid != 4'd1) begin // 1 next does not overlap with wall
                    if ((next_ghost2_x1 != next_ghost1_min_x) | (next_ghost2_y1 != next_ghost1_min_y)) begin // 2 next doesn't overlap with 1 next
                        if ((next_ghost2_x1 != curr_ghost1_x) | (next_ghost2_y1 != curr_ghost1_y)) begin // 2 next doesn't overlap with 1 curr
                            if ((next_ghost2_x1 != prev_ghost2_x) | (next_ghost2_y1 != prev_ghost2_y)) begin // 2 next doesn't overlap with 2 prev
                                if ((x_diff + y_diff) < next_ghost2_min_val) begin
                                    next_ghost2_min_val = x_diff + y_diff;
                                    next_ghost2_min_x = next_ghost2_x1;
                                    next_ghost2_min_y = next_ghost2_y1;
                                end 
                            end
                        end
                    end
				end
			end
            check2_2_hold1: begin
                ns = check2_2_hold2;
                rdaddr_x = next_ghost2_x2;
				    rdaddr_y = next_ghost2_y2;
            end
            check2_2_hold2: begin
                ns = check2_2;
                rdaddr_x = next_ghost2_x2;
				    rdaddr_y = next_ghost2_y2;
            end
			check2_2: begin // check down (change y from previous state)
				ns = check2_3_hold1; 
				x_diff = (next_ghost2_x2 > curr_pacman_x) ? (next_ghost2_x2 - curr_pacman_x) : (curr_pacman_x - next_ghost2_x2);
				y_diff = (next_ghost2_y2 > curr_pacman_y) ? (next_ghost2_y2 - curr_pacman_y) : (curr_pacman_y - next_ghost2_y2);
				rdaddr_x = next_ghost2_x2;
				rdaddr_y = next_ghost2_y3;
				if (main_map_grid != 4'd1) begin // 1 next does not overlap with wall
                    if ((next_ghost2_x2 != next_ghost1_min_x) | (next_ghost2_y2 != next_ghost1_min_y)) begin // 2 next doesn't overlap with 1 next
                        if ((next_ghost2_x2 != curr_ghost1_x) | (next_ghost2_y2 != curr_ghost1_y)) begin // 2 next doesn't overlap with 1 curr
                            if ((next_ghost2_x2 != prev_ghost2_x) | (next_ghost2_y2 != prev_ghost2_y)) begin // 2 next doesn't overlap with 2 prev
                                if ((x_diff + y_diff) < next_ghost2_min_val) begin
                                    next_ghost2_min_val = x_diff + y_diff;
                                    next_ghost2_min_x = next_ghost2_x2;
                                    next_ghost2_min_y = next_ghost2_y2;
                                end 
                            end
                        end
                    end
				end
			end
            check2_3_hold1: begin
                ns = check2_3_hold2;
                rdaddr_x = next_ghost2_x3;
				    rdaddr_y = next_ghost2_y3;
            end
            check2_3_hold2: begin
                ns = check2_3;
                rdaddr_x = next_ghost2_x3;
				    rdaddr_y = next_ghost2_y3;
            end
			check2_3: begin // check left (change y from previous state)
				ns = check2_4_hold1; 
				x_diff = (next_ghost2_x3 > curr_pacman_x) ? (next_ghost2_x3 - curr_pacman_x) : (curr_pacman_x - next_ghost2_x3);
				y_diff = (next_ghost2_y3 > curr_pacman_y) ? (next_ghost2_y3 - curr_pacman_y) : (curr_pacman_y - next_ghost2_y3);
				rdaddr_x = next_ghost2_x3;
				rdaddr_y = next_ghost2_y4;
				if (main_map_grid != 4'd1) begin // 1 next does not overlap with wall
                    if ((next_ghost2_x3 != next_ghost1_min_x) | (next_ghost2_y3 != next_ghost1_min_y)) begin // 2 next doesn't overlap with 1 next
                        if ((next_ghost2_x3 != curr_ghost1_x) | (next_ghost2_y3 != curr_ghost1_y)) begin // 2 next doesn't overlap with 1 curr
                            if ((next_ghost2_x3 != prev_ghost2_x) | (next_ghost2_y3 != prev_ghost2_y)) begin // 2 next doesn't overlap with 2 prev
                                if ((x_diff + y_diff) < next_ghost2_min_val) begin
                                    next_ghost2_min_val = x_diff + y_diff;
                                    next_ghost2_min_x = next_ghost2_x3;
                                    next_ghost2_min_y = next_ghost2_y3;
                                end 
                            end
                        end
                    end
				end
			end
            check2_4_hold1: begin
                ns = check2_4_hold2;
                rdaddr_x = next_ghost2_x4;
				rdaddr_y = next_ghost2_y4;
            end
            check2_4_hold2: begin
                ns = check2_4;
                rdaddr_x = next_ghost2_x4;
				rdaddr_y = next_ghost2_y4;
            end
			check2_4: begin // check right (doesn't change y from previous state)
				ns = done;
				x_diff = (next_ghost2_x4 > curr_pacman_x) ? (next_ghost2_x4 - curr_pacman_x) : (curr_pacman_x - next_ghost2_x4);
				y_diff = (next_ghost2_y4 > curr_pacman_y) ? (next_ghost2_y4 - curr_pacman_y) : (curr_pacman_y - next_ghost2_y4);
				rdaddr_x = next_ghost2_x4; 
				rdaddr_y = next_ghost2_y4;
				if (main_map_grid != 4'd1) begin // 1 next does not overlap with wall
                    if ((next_ghost2_x4 != next_ghost1_min_x) | (next_ghost2_y4 != next_ghost1_min_y)) begin // 2 next doesn't overlap with 1 next
                        if ((next_ghost2_x4 != curr_ghost1_x) | (next_ghost2_y4 != curr_ghost1_y)) begin // 2 next doesn't overlap with 1 curr
                            if ((next_ghost2_x4 != prev_ghost2_x) | (next_ghost2_y4 != prev_ghost2_y)) begin // 2 next doesn't overlap with 2 prev
                                if ((x_diff + y_diff) < next_ghost2_min_val) begin
                                    next_ghost2_min_val = x_diff + y_diff;
                                    next_ghost2_min_x = next_ghost2_x4;
                                    next_ghost2_min_y = next_ghost2_y4;
                                end 
                            end
                        end
                    end
				end
			end
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
         main_map_reg1 <= 0;
         main_map_reg2 <= 0;
			end
		else begin
			   ps <= ns;
            main_map_reg1 <= main_map_out;
            main_map_reg2 <= main_map_reg1;
			if (ps == done) begin
				if (count2 > 0) begin
					next_ghost1_x <= 6'd16;
					next_ghost1_y <= 5'd13;
					end
				else begin
					next_ghost1_x <= next_ghost1_min_x;
					next_ghost1_y <= next_ghost1_min_y;
					end
				if (count3 > 0) begin
					next_ghost2_x <= 6'd23;
					next_ghost2_y <= 5'd13;
					end
				else begin
					next_ghost2_x <= next_ghost2_min_x;
					next_ghost2_y <= next_ghost2_min_y;
					end
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
	end // always_ff

	
endmodule


// testbench for ghost_loc_ctrl
`timescale 1 ps / 1 ps
module ghosts_ai_testbench();
	logic CLOCK_50, reset;
	logic wrdone, enable, ghostCollision1, ghostCollision2;
	logic [5:0] curr_pacman_x;
	logic [4:0] curr_pacman_y;
	logic [5:0] next_ghost1_x, next_ghost2_x;
	logic [4:0] next_ghost1_y, next_ghost2_y;
	logic [5:0] curr_ghost1_x, curr_ghost2_x;
	logic [4:0] curr_ghost1_y, curr_ghost2_y;

	parameter DELAY = 40;
	ghosts_ai #(DELAY) dut (.*);
	parameter CLOCK_PERIOD = 100;
	initial begin
        CLOCK_50 <= 0;
        forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
    end

	initial begin
		reset <= 1; enable <= 1; @(posedge CLOCK_50);
		curr_pacman_x <= 20; curr_pacman_y <= 20; reset <= 0; @(posedge CLOCK_50);
		for (int tot = 0; tot < 25; tot ++) begin
			for (int i = 0; i < 40; i ++) begin
			    @(posedge CLOCK_50);
			end
			wrdone <= 1; @(posedge CLOCK_50);
			wrdone <= 0; @(posedge CLOCK_50);
		end
		$stop;
	end
endmodule

// Winston Chen
// Connor Lowe
// 1573616
// 5/3/2020
// EE 371
// Lab 6
//
// This module keeps track of pacman's current and next location on the game map.
// This module inputs clock, reset, and the up, down, right, and left control signals.
// This module outputs the current and next location of pacman given the control signals.
// This module also outputs a 4-bit collision type representing the current collision of pacman
//  and a 33-bit pill_count that represents the ammount of time left that pacman is immune to ghosts.
//  Eating a pill increases the pill_count by about 30 seconds. 
module pacman_loc_ctrl(CLOCK_50, reset, done, up, down, left, right, pill_count, collision_type,
                       curr_pacman_x, curr_pacman_y, next_pacman_x, next_pacman_y);
    input logic CLOCK_50, reset, done; // done: from RAM write module that indicates curr position has been removed and next position has been write
    input logic up, down, left, right;
	output logic [32:0] pill_count;
    output logic [5:0] curr_pacman_x, next_pacman_x; 
    output logic [4:0] curr_pacman_y, next_pacman_y;
    output logic [3:0] collision_type;
    enum {still, hold, move} ps, ns;


    logic [5:0] temp_next_pacman_x;   
    logic [4:0] temp_next_pacman_y;
    logic [3:0] direction;
    logic colli_clr;
    assign direction = {up, down, left, right}; // should only be one hot
	 
	// instantiate collision detect module 
	collision_detect collisions (.CLOCK_50(CLOCK_50), .reset(reset), .colli_clr(colli_clr),
											.next_pacman_x(temp_next_pacman_x),
											.next_pacman_y(temp_next_pacman_y), 
											.collision_type(collision_type), .pill_count(pill_count));
	
	// latched block determing the next location of pacman 								
    always_latch begin
        colli_clr = 0;
        case (ps) 
            still: begin
                ns = hold;
                if (direction == 4'b0000) begin
                    ns = still;
                    colli_clr = 1;
                    next_pacman_x = curr_pacman_x;
                    next_pacman_y = curr_pacman_y;
					 end
                else begin 
                    if (up) begin
                        temp_next_pacman_x = curr_pacman_x;
                        temp_next_pacman_y = curr_pacman_y - 1;
                    end 
                    else if (down) begin
                        temp_next_pacman_x = curr_pacman_x;
                        temp_next_pacman_y = curr_pacman_y + 1;
                    end
                    else if (left) begin
                        temp_next_pacman_x = curr_pacman_x - 1;
                        temp_next_pacman_y = curr_pacman_y;
                    end
                    else if (right) begin
                        temp_next_pacman_x = curr_pacman_x + 1;
                        temp_next_pacman_y = curr_pacman_y;
                    end
                end
            end // closes still state
            hold: begin
                ns = move;
            end // closes hold state
            move: begin
                // block determining next pacman location based on if it is a valid move
                if (collision_type == 4'b0001) begin // collide with wall
                    next_pacman_x = curr_pacman_x;
                    next_pacman_y = curr_pacman_y;
                    ns = still;
                end
                else begin
                    next_pacman_x = temp_next_pacman_x;
                    next_pacman_y = temp_next_pacman_y;
                    if (done) ns = still;
                    else ns = move;
                end
            end // closes move state
        endcase
    end // always_latch

	 // sequential logic block setting current pacman location
    always_ff @(posedge CLOCK_50) begin
        if (reset) begin
            ps <= still;
            curr_pacman_x <= 6'd20;
            curr_pacman_y <= 5'd20;
        end 
        else begin
            ps <= ns;
            if (done) begin
                curr_pacman_x <= next_pacman_x;
                curr_pacman_y <= next_pacman_y;
            end
            else begin
                curr_pacman_x <= curr_pacman_x;
                curr_pacman_y <= curr_pacman_y;
            end
        end
    end // always_ff
	 
endmodule // closes pacman location control module


// This module tests the pacman location control module with intent to utilize ModelSim.
// Varies input to ensure the out signals is sent as expected.
`timescale 1 ps / 1 ps
module pacman_loc_ctrl_testbench();
    logic CLOCK_50, reset, done; // done: from RAM write module that indicates curr position has been removed and next position has been write
    logic up, down, left, right;
    logic [32:0] pill_count;
    logic [5:0] curr_pacman_x, next_pacman_x; 
    logic [4:0] curr_pacman_y, next_pacman_y;
	 logic [3:0] direction, collision_type;

    assign {up, down, left, right} = direction;

	 // instantiate map ram writer
    map_RAM_writer map_wr (.CLOCK_50, .reset,
                      .curr_pacman_x, .curr_pacman_y, .next_pacman_x, .next_pacman_y, 
                      .curr_ghost1_x(6'd16), .curr_ghost1_y(6'd13), .next_ghost1_x(6'd16), .next_ghost1_y(6'd13), 
                      .curr_ghost2_x(6'd23), .curr_ghost2_y(6'd13), .next_ghost2_x(6'd23), .next_ghost2_y(6'd13),
                      .redata(), .wren(), .pac_done(done), .ghost_done(), .wraddr(), .wrdata());
							 
	 // utilizing verilog's implicit port connections
    pacman_loc_ctrl dut (.*);

	// block that sets up the clock
	parameter CLOCK_PERIOD = 100;
    initial begin
        CLOCK_50 <= 0;
        forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
    end

	 // block that sets inputs for design
    initial begin
        reset <= 1; @(posedge CLOCK_50);
        reset <= 0; done <= 0; direction <= 4'b0000; @(posedge CLOCK_50);
        for (int i = 0; i < 60; i ++) begin
            @(posedge CLOCK_50);
        end
        for (int i = 0; i < 8; i ++) begin
            direction <= 4'b0010; @(posedge CLOCK_50);
            direction <= 4'b0000; @(posedge CLOCK_50);
                                  @(posedge CLOCK_50);
                                  @(posedge CLOCK_50);
                                  @(posedge CLOCK_50);
                                  @(posedge CLOCK_50);
                                  @(posedge CLOCK_50);
        end
        for (int i = 0; i < 3; i ++) begin
            direction <= 4'b0100; @(posedge CLOCK_50);
            direction <= 4'b0000; @(posedge CLOCK_50);
                                  @(posedge CLOCK_50);
                                  @(posedge CLOCK_50);
                                  @(posedge CLOCK_50);
                                  @(posedge CLOCK_50);
                                  @(posedge CLOCK_50);
        end
        for (int i = 0; i < 6; i ++) begin
            direction <= 4'b0010; @(posedge CLOCK_50);
            direction <= 4'b0000; @(posedge CLOCK_50);
                                  @(posedge CLOCK_50);
                                  @(posedge CLOCK_50);
                                  @(posedge CLOCK_50);
                                  @(posedge CLOCK_50);
                                  @(posedge CLOCK_50);
        end
        for (int i = 0; i < 7; i ++) begin
            direction <= 4'b0100; @(posedge CLOCK_50);
            direction <= 4'b0000; @(posedge CLOCK_50);
                                  @(posedge CLOCK_50);
                                  @(posedge CLOCK_50);
                                  @(posedge CLOCK_50);
                                  @(posedge CLOCK_50);
                                  @(posedge CLOCK_50);
        end
        
        $stop;
    end // closes block setting inputs to design
endmodule // closes module testing pacman location control
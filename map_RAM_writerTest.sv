// This module takes in sprits' new current and new location and then 
// generate control signals that writes the new location information
// into the map ram 
module map_RAM_writerTest(CLOCK_50, reset, start,
                      curr_pacman_x, curr_pacman_y, next_pacman_x, next_pacman_y, 
                      curr_ghost1_x, curr_ghost1_y, next_ghost1_x, next_ghost1_y, 
                      curr_ghost2_x, curr_ghost2_y, next_ghost2_x, next_ghost2_y,
                      redata, wren, pac_done, ghost_done, wraddr, wrdata);
    input logic CLOCK_50, reset, start;
    input logic [5:0] curr_pacman_x, next_pacman_x, curr_ghost1_x, curr_ghost2_x, 
							 next_ghost1_x, next_ghost2_x;// Has to keep the same for at least 3 clk cycle
    input logic [4:0] curr_pacman_y, next_pacman_y, curr_ghost1_y, curr_ghost2_y,
							 next_ghost1_y, next_ghost2_y; // Has to keep the same for at least 3 clk cycle
    input logic [159:0] redata; // data read from map RAM at the wraddr
    output logic wren, pac_done, ghost_done; // when done is asserted curr_pacman and next_pacman should be set to equal by exterior module
    output logic [4:0] wraddr;
    output logic [159:0] wrdata; // data being written into map RAM at wraddr

    logic [3:0] curr_pacman, curr_ghost, next_obj, wrgrid;

    enum {init, init2, remove_pac, wait_pac_put, wait_pac_put2, put_pac, wait_ghost1_remove, remove_ghost1, wait_ghost1_put, put_ghost1, 
		  wait_ghost2_remove, remove_ghost2, wait_ghost2_put, put_ghost2} ps, ns;

    always_latch begin
 	    pac_done = 0;
        ghost_done = 0;
        case(ps)
            init: begin // wait state 
					if ((curr_pacman_x != next_pacman_x) | (curr_pacman_y != next_pacman_y)) ns = remove_pac;
               else if ((curr_ghost1_x != next_ghost1_x) | (curr_ghost1_y != next_ghost1_y) |
                         (curr_ghost2_x != next_ghost2_x) | (curr_ghost2_y != next_ghost2_y)) begin
                             ns = wait_ghost1_remove;                            
                         end
					else ns = init;
					wraddr = curr_pacman_y;
            end
            remove_pac: begin // state that remove previous pacman from map RAM
                ns = wait_pac_put;
                wraddr = curr_pacman_y;
                wrdata = redata;
                wrgrid = 4'd0;
                wrdata[159-(4*curr_pacman_x+3)+:4] = wrgrid;
            end
            wait_pac_put: begin 
                ns = put_pac;
                wraddr = next_pacman_y;
            end
            put_pac: begin// state that write next pacman into map RAM
                ns = init;
					 wraddr = next_pacman_y;
                next_obj = redata[159-(4*next_pacman_y+3)+:4];
                wrdata = redata;
                wrdata[159-(4*next_pacman_x+3)+:4] = 4'd4;
                pac_done = 1;
            end
            wait_ghost1_remove: begin 
                ns = remove_ghost1;
                wraddr = curr_ghost1_y;
            end
            remove_ghost1: begin // state that remove previous ghost1 ghost from map RAM
                ns = wait_ghost1_put;
                wraddr = curr_ghost1_y;
                wrdata = redata;
                curr_ghost = redata[159-(4*curr_ghost1_x+3)+:4]; 
                assert (curr_ghost >= 5);
                if (curr_ghost == 4'd5) begin // if ghost does not overlay with anything
                    wrgrid = 4'd0; 
                end
                else begin // if ghost overlay with dot or pill
                    wrgrid = curr_ghost - 4;
                end
                wrdata[159-(4*curr_ghost1_x+3)+:4]  = wrgrid;
            end
            wait_ghost1_put: begin 
                ns = put_ghost1;
                wraddr = next_ghost1_y;
            end
            put_ghost1: begin // state that write next ghost1 into map RAM
                ns = wait_ghost2_remove;
                wraddr = next_ghost1_y;
                wrdata = redata;
                next_obj = redata[159-(4*next_ghost1_x+3)+:4]; 
                if (next_obj == 4'd0 | next_obj == 4'd4) begin
                    wrgrid = 4'd5;
                end
                else if (next_obj >=  4'd5) begin
                    wrgrid = next_obj;
                end
                else begin
                    wrgrid = next_obj + 4;
                end
                wrdata[159-(4*next_ghost1_x+3)+:4] = wrgrid;
            end
            wait_ghost2_remove: begin
                ns = remove_ghost2;
                wraddr = curr_ghost2_y;
            end
            remove_ghost2: begin // state that remove previous ghost2 from map RAM
                ns = wait_ghost2_put;
                wraddr = curr_ghost2_y;
                wrdata = redata;
                curr_ghost = redata[159-(4*curr_ghost2_x+3)+:4]; 
                assert (curr_ghost >= 5);
                if (curr_ghost == 4'd5) begin // if ghost does not overlay with anything
                    wrgrid = 4'd0;
                end
                else begin // if ghost overlay with dot or pill
                    wrgrid = curr_ghost - 4;
                end
                wrdata[159-(4*curr_ghost2_x+3)+:4] = wrgrid;
            end
            wait_ghost2_put: begin 
                ns = put_ghost2;
                wraddr = next_ghost2_y;
            end
            put_ghost2: begin // state that put next ghost 2 into map RAM
                ns = init;
                wraddr = next_ghost2_y;
                wrdata = redata;
                next_obj = redata[159-(4*next_ghost2_x+3)+:4]; 
                if (next_obj == 4'd0 | next_obj == 4'd4) begin
                    wrgrid = 4'd5;
                end
                else if (next_obj >=  4'd5) begin
                    wrgrid = next_obj;
                end
                else begin
                    wrgrid = next_obj + 4;
                end
                wrdata[159-(4*next_ghost2_x+3)+:4] = wrgrid;
                ghost_done = 1;
            end
		endcase
    end
    assign wren = ((ps == remove_pac) | (ps == put_pac) | (ps == remove_ghost1) | (ps == put_ghost1) |
                   (ps == remove_ghost2) | (ps == put_ghost2)); // enable map_ram write


    always_ff @(posedge CLOCK_50) begin
        if (reset) begin
            ps <= init;
        end
        else begin
            ps <= ns;
        end
    end
endmodule

// testbench for map_RAM_writer
`timescale 1 ps / 1 ps
module map_RAM_writerTest_testbench();
    logic CLOCK_50, reset, start;
    logic [5:0] curr_pacman_x, next_pacman_x, curr_ghost1_x, curr_ghost2_x, 
				next_ghost1_x, next_ghost2_x, temp_next_pacman_x; // Has to keep the same for at least 3 clk cycle
    logic [4:0] curr_pacman_y, next_pacman_y, curr_ghost1_y, curr_ghost2_y,
				next_ghost1_y, next_ghost2_y, temp_next_pacman_y; // Has to keep the same for at least 3 clk cycle
    logic [159:0] redata; // data read from map RAM at the wraddr
    logic wren, pac_done, ghost_done;
    logic [4:0] wraddr;
    logic [159:0] wrdata; // data being written into map RAM at wraddr
    logic up, down, left, right;
    logic [3:0] direction;
    logic [3:0] collision_type;
    logic [32:0] pill_count;
    assign {up, down, left, right} = direction;

    map_RAM m (.address_a(), .address_b(wraddr), .clock(CLOCK_50), .data_a(), .data_b(wrdata), .wren_a(), .wren_b(wren), .q_a(), .q_b(redata));
    collision_detect collisions (.CLOCK_50(CLOCK_50), .reset(reset), .next_pacman_x(temp_next_pacman_x),
								.next_pacman_y(temp_next_pacman_y), .next_ghost1_x(next_ghost1_x),
								.next_ghost1_y(next_ghost1_y), .next_ghost2_x(next_ghost2_x), .next_ghost2_y(next_ghost2_y),
								.collision_type(collision_type), .pill_count(pill_count));
    pacman_loc_ctrl pac_loc (.CLOCK_50, .reset(reset), .done(pac_done), .up(up), .down(down), .left(left), .right(right), 
                            .collision_type(collision_type), .pill_count(pill_count),
                            .curr_pacman_x(curr_pacman_x), .curr_pacman_y(curr_pacman_y), .next_pacman_x(next_pacman_x), 
                            .next_pacman_y(next_pacman_y), .temp_next_pacman_x(temp_next_pacman_x), .temp_next_pacman_y(temp_next_pacman_y));
    ghosts_loc_ctrl ghost_loc
		 (.CLOCK_50, .reset, .curr_pacman_x, .curr_pacman_y, .collision_type(), .pill_counter(),
		  .wrdone(ghost_done), .curr_ghost1_x, .curr_ghost1_y, .curr_ghost2_x, .curr_ghost2_y,
		  .next_ghost1_x, .next_ghost1_y, .next_ghost2_x, .next_ghost2_y);
    map_RAM_writerTest dut (.*);

    parameter CLOCK_PERIOD = 100;
    initial begin
        CLOCK_50 <= 0;
        forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
    end

    initial begin
        
        start <= 0; reset <= 1; @(posedge CLOCK_50);
        start <= 1; reset <= 0; direction <= 4'b0000; @(posedge CLOCK_50);
        /*
        reset <= 0; @(posedge CLOCK_50);
		for (int i = 0; i < 240000; i ++) begin
			@(posedge CLOCK_50);
		end
		for (int i = 0; i < 11; i ++) begin
			@(posedge CLOCK_50);
        end
        
        */
        direction <= 4'b1000; @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
        direction <= 4'b0000; @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
        direction <= 4'b0100; @(posedge CLOCK_50);
        direction <= 4'b0000; @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
        direction <= 4'b0100; @(posedge CLOCK_50);
        direction <= 4'b0000; @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
        direction <= 4'b0100; @(posedge CLOCK_50);
        direction <= 4'b0000; @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
        direction <= 4'b0010; @(posedge CLOCK_50);
        direction <= 4'b0000; @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
        direction <= 4'b0001; @(posedge CLOCK_50);
        direction <= 4'b0000; @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
        direction <= 4'b0100; @(posedge CLOCK_50);
        direction <= 4'b0000; @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
        direction <= 4'b0010; @(posedge CLOCK_50);
        direction <= 4'b0000; @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
        direction <= 4'b0010; @(posedge CLOCK_50);
        direction <= 4'b0000; @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
        direction <= 4'b0001; @(posedge CLOCK_50);
        direction <= 4'b0000; @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
		
		
        $stop;                @(posedge CLOCK_50);
    end
endmodule

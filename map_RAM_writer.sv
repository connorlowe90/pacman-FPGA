// Winston Chen
// Connor Lowe
// 1573616
// 5/3/2020
// EE 371
// Lab 6
//
// This module takes in sprits' new current and new location and then 
// generate control signals that writes the new location information
// into the map ram 
module map_RAM_writer(CLOCK_50, reset,
                      curr_pacman_x, curr_pacman_y, next_pacman_x, next_pacman_y, 
                      curr_ghost1_x, curr_ghost1_y, next_ghost1_x, next_ghost1_y, 
                      curr_ghost2_x, curr_ghost2_y, next_ghost2_x, next_ghost2_y,
                      redata, wren, pac_done, ghost_done, wraddr, wrdata);
    input logic CLOCK_50, reset;
    input logic [5:0] curr_pacman_x, next_pacman_x, curr_ghost1_x, curr_ghost2_x, 
							 next_ghost1_x, next_ghost2_x;// Has to keep the same for at least 3 clk cycle
    input logic [4:0] curr_pacman_y, next_pacman_y, curr_ghost1_y, curr_ghost2_y,
							 next_ghost1_y, next_ghost2_y; // Has to keep the same for at least 3 clk cycle
    input logic [159:0] redata; // data read from map RAM at the wraddr
    output logic wren, pac_done, ghost_done; // when done is asserted curr_pacman and next_pacman should be set to equal by exterior module
    output logic [4:0] wraddr;
    output logic [159:0] wrdata; // data being written into map RAM at wraddr

    logic [4:0] reset_addr;
    logic [159:0] reset_word;
    map_RAM reset_map 
			(.address_a(reset_addr), .address_b(), .clock(CLOCK_50), 
			 .data_a(), .data_b(), .wren_a(1'b0), .wren_b(1'b0), .q_a(reset_word), .q_b()); 

    logic [3:0] curr_pacman, curr_ghost, next_obj, wrgrid;

    enum {reset_mem, reset_mem_hold, init, remove_pac, wait_pac_put, put_pac, 
          wait_ghost1_remove, remove_ghost1, wait_ghost1_put, put_ghost1, 
		  wait_ghost2_remove, remove_ghost2, wait_ghost2_put, put_ghost2} ps, ns;

    always_comb begin
		wraddr = 5'bX;
        wrdata = 159'bX;
 	    pac_done = 0;
        ghost_done = 0;
        curr_pacman = 4'bX;
		curr_ghost = 4'bX;
		next_obj = 4'bX;
        wrgrid = 4'bX;
        case(ps)
            reset_mem: begin
                ns = reset_mem_hold;
                wraddr = reset_addr;
                wrdata = reset_word;
            end
            reset_mem_hold: begin
                if (reset_addr == 5'd29) ns = init;
                else ns = reset_mem;
                wraddr = reset_addr;
                wrdata = reset_word;
            end
            init: begin // wait state 
                if ((curr_pacman_x != next_pacman_x) | (curr_pacman_y != next_pacman_y)) begin // signal ready and changed
                    ns = remove_pac;
                end
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
                // testing
                curr_pacman = redata[159-(4*curr_pacman_x+3)+:4];
                // assert (curr_pacman == 4'd4);
                wrgrid = 4'd0;
                wrdata[159-(4*curr_pacman_x+3)+:4] = wrgrid;
            end
            wait_pac_put: begin 
                ns = put_pac;
                wraddr = next_pacman_y;
            end
            put_pac: begin// state that write next pacman into map RAM
                if ((curr_ghost1_x != next_ghost1_x) | (curr_ghost1_y != next_ghost1_y) |
                    (curr_ghost2_x != next_ghost2_x) | (curr_ghost2_y != next_ghost2_y)) begin
                           ns = wait_ghost1_remove;
                       end
                else ns = init;
                wraddr = next_pacman_y;
                next_obj = redata[159-(4*next_pacman_x+3)+:4];
                wrdata = redata;
                wrgrid = 4'd4;
                wrdata[159-(4*next_pacman_x+3)+:4] = wrgrid;
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
                // assert (curr_ghost >= 5);
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
                // assert (curr_ghost >= 5);
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
                   (ps == remove_ghost2) | (ps == put_ghost2) | (ps == reset_mem_hold)); // enable map_ram write


    always_ff @(posedge CLOCK_50) begin
        if (reset) begin
            ps <= reset_mem;
            reset_addr <= 5'd0;
        end
        else begin
            if (ps == reset_mem_hold) reset_addr <= reset_addr + 1;
            else reset_addr = reset_addr;
            ps <= ns;
        end
    end
endmodule // closes module


// This module tests the keyboard_process module with intent to utilize ModelSim.
// Varies input to ensure the out signals is sent as expected.
`timescale 1 ps / 1 ps
module map_RAM_writer_testbench();
    logic CLOCK_50, reset, enable;
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
    logic [32:0] pill_count;
    assign {up, down, left, right} = direction;

	 // instantiate map RAM
    map_RAM m (.address_a(), .address_b(wraddr), .clock(CLOCK_50), .data_a(), .data_b(wrdata), .wren_a(), .wren_b(wren), .q_a(), .q_b(redata));
 
    // instantiate pacman location control
    pacman_loc_ctrl pac_loc (.CLOCK_50, .reset(reset), .done(pac_done), .up(up), .down(down), .left(left), .right(right), .pill_count(pill_count),
                             .curr_pacman_x(curr_pacman_x), .curr_pacman_y(curr_pacman_y), .next_pacman_x(next_pacman_x), .next_pacman_y(next_pacman_y));

	 // instantiate ghost ai
    parameter DELAY = 100;
    ghosts_ai #(DELAY) ghost_loc
                    (.CLOCK_50(CLOCK_50), .reset(reset), .enable(enable), .curr_pacman_x(curr_pacman_x), .curr_pacman_y(curr_pacman_y),
                     .wrdone(ghost_done), .curr_ghost1_x(curr_ghost1_x), .curr_ghost1_y(curr_ghost1_y), 
							.curr_ghost2_x(curr_ghost2_x), .curr_ghost2_y(curr_ghost2_y),
                     .next_ghost1_x(next_ghost1_x), .next_ghost1_y(next_ghost1_y), 
							.next_ghost2_x(next_ghost2_x), .next_ghost2_y(next_ghost2_y));
							
	 // utilizing verilog's implicit port connections
    map_RAM_writer dut (.*);

	 // block setting up the clock
    parameter CLOCK_PERIOD = 100;
    initial begin
        CLOCK_50 <= 0;
        forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
    end // closes block setting up the clock

	 // block setting inputs to the design
    initial begin
        
        enable <= 0; reset <= 1; @(posedge CLOCK_50);
        direction <= 4'b0000; @(posedge CLOCK_50);
        reset <= 0; @(posedge CLOCK_50);
		  
		  for (int i = 0; i < 61; i ++ ) begin
				@(posedge CLOCK_50);
		  end
        enable <= 1; @(posedge CLOCK_50);
        for (int j = 0; j < 25; j ++) begin
            for (int i = 0; i < 100; i ++) begin
                @(posedge CLOCK_50);
            end
        end
        
        for (int j = 0; j < 9; j ++) begin
        direction <= 4'b0010; @(posedge CLOCK_50);
        direction <= 4'b0000; @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
		  end 
		  
        direction <= 4'b1000; @(posedge CLOCK_50);
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
        direction <= 4'b0100; @(posedge CLOCK_50);
        direction <= 4'b0000; @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
        $stop;                @(posedge CLOCK_50);
    end // closes block setting inputs to the design
endmodule // closes testbench

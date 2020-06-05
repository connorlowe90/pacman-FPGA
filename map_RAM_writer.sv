// This module takes in sprits' new current and new location and then 
// generate control signals that writes the new location information
// into the map ram 
module map_RAM_writer(CLOCK_50, reset, curr_pacman_x, curr_pacman_y, next_pacman_x, next_pacman_y, redata, wren, done, wraddr, wrdata);
    input logic CLOCK_50, reset;
    input logic [5:0] curr_pacman_x, next_pacman_x; // Has to keep the same for at least 3 clk cycle
    input logic [4:0] curr_pacman_y, next_pacman_y; // Has to keep the same for at least 3 clk cycle
    input logic [159:0] redata; // data read from map RAM at the wraddr
    output logic wren, done; // when done is asserted curr_pacman and next_pacman should be set to equal by exterior module
    output logic [4:0] wraddr;
    output logic [159:0] wrdata; // data being written into map RAM at wraddr

    logic [3:0] curr_pacman;

    enum {init, remove, put_wait, put} ps, ns;

    always_comb begin
		wraddr = 5'bX;
        wrdata = 159'bX;
 	    done = 0;
        curr_pacman = 4'bX;
        case(ps)
            init: begin
                if ((curr_pacman_x == next_pacman_x) & (curr_pacman_y == next_pacman_y)) ns = init;
                else ns = remove;
                wraddr = curr_pacman_y;
            end
            remove: begin
                ns = put_wait;
                wraddr = curr_pacman_y;
                wrdata = redata;
                curr_pacman = wrdata[159-(4*curr_pacman_x+3)+:4];
                assert (curr_pacman == 4'd4);
                wrdata[159-(4*curr_pacman_x+3)+:4] = 4'd0;
            end
            put_wait: begin
                ns = put;
                wraddr = next_pacman_y;
            end
            put: begin
                ns = init;
                wraddr = next_pacman_y;
                wrdata = redata;
                wrdata[159-(4*next_pacman_x+3)+:4] = 4'd4;
                done = 1;
            end
		endcase
    end
    assign wren = ((ps == remove) | (ps == put));


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
module map_RAM_writer_testbench();
    logic CLOCK_50, reset;
    logic [5:0] curr_pacman_x, next_pacman_x; // Has to keep the same for at least 3 clk cycle
    logic [4:0] curr_pacman_y, next_pacman_y; // Has to keep the same for at least 3 clk cycle
    logic [159:0] redata; // data read from map RAM at the wraddr
    logic wren, done;
    logic [4:0] wraddr;
    logic [159:0] wrdata; // data being written into map RAM at wraddr
    logic up, down, left, right;
    logic [3:0] direction;
    assign {up, down, left, right} = direction;

    map_RAM m (.address_a(), .address_b(wraddr), .clock(CLOCK_50), .data_a(), .data_b(wrdata), .wren_a(), .wren_b(wren), .q_a(), .q_b(redata));
    pacman_loc_ctrl pac_loc (.CLOCK_50, .reset, .done, .up, .down, .left, .right, .curr_pacman_x, .curr_pacman_y, .next_pacman_x, .next_pacman_y);
    map_RAM_writer dut (.*);

    parameter CLOCK_PERIOD = 100;
    initial begin
        CLOCK_50 <= 0;
        forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
    end

    initial begin 
        reset <= 1; @(posedge CLOCK_50);
        reset <= 0; done <= 0; direction <= 4'b0000; @(posedge CLOCK_50);
        direction <= 4'b1000; @(posedge CLOCK_50);
        direction <= 4'b0000; @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
        done <= 1;            @(posedge CLOCK_50);
        done <= 0; direction <= 4'b0100; @(posedge CLOCK_50);
        direction <= 4'b0000; @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
        done <= 1;            @(posedge CLOCK_50);
        done <= 0; direction <= 4'b0100; @(posedge CLOCK_50);
        direction <= 4'b0000; @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
        done <= 1;            @(posedge CLOCK_50);
        done <= 0; direction <= 4'b0100; @(posedge CLOCK_50);
        direction <= 4'b0000; @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
        done <= 1;            @(posedge CLOCK_50);
        done <= 0; direction <= 4'b0010; @(posedge CLOCK_50);
        direction <= 4'b0000; @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
        done <= 1;            @(posedge CLOCK_50);
        done <= 0; direction <= 4'b0001; @(posedge CLOCK_50);
        direction <= 4'b0000; @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
        done <= 1;            @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
        done <= 0; direction <= 4'b0100; @(posedge CLOCK_50);
        direction <= 4'b0000; @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
                              @(posedge CLOCK_50);
        done <= 1;            @(posedge CLOCK_50);
        $stop;                @(posedge CLOCK_50);
    end
endmodule

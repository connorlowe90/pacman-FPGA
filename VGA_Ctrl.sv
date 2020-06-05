// EE 371 Lab 6 
// Winston Chen
// Connor Lowe
// This VGA control moduel would read from multiple ROM that stores the graphic design of Pacman game
// and output them to the VGA buffer
module VGA_Ctrl (CLOCK_50, reset, obj_x, obj_y, obj, r, g, b);
    input logic CLOCK_50, reset;
    input logic [3:0] obj_x;
    input logic [3:0] obj_y;
    input logic [3:0] obj;
    output logic [7:0] r, g, b;

    // read Wall object image
    logic [0:15] wall_word;
    logic [7:0] wall_r_pixel, wall_g_pixel, wall_b_pixel;
    wall_ROM wall (.address(obj_y), .clock(CLOCK_50), .q(wall_word));
    assign wall_r_pixel = wall_word[obj_x] ? 8'd62 : 8'd0;
    assign wall_g_pixel = wall_word[obj_x] ? 8'd54 : 8'd0;
    assign wall_b_pixel = wall_word[obj_x] ? 8'd209 : 8'd0;
	 
	 // read pacman object image
    logic [0:15]pacman_word;
    logic [7:0]pacman_r_pixel, pacman_g_pixel, pacman_b_pixel;
    pacman_ROM pac (.address(obj_y), .clock(CLOCK_50), .q(pacman_word));
    assign pacman_r_pixel = pacman_word[obj_x] ? 8'd245 : 8'd0;
    assign pacman_g_pixel = pacman_word[obj_x] ? 8'd224 : 8'd0;
    assign pacman_b_pixel = pacman_word[obj_x] ? 8'd66 : 8'd0;
	 
	 // read dot object image
	 logic [0:15]dot_word;
	 logic [7:0]dot_r_pixel, dot_g_pixel, dot_b_pixel;
	 dot_ROM dot (.address(obj_y), .clock(CLOCK_50), .q(dot_word));
	 assign dot_r_pixel = dot_word[obj_x] ? 8'd255 : 8'd0;
	 assign dot_g_pixel = dot_word[obj_x] ? 8'd255 : 8'd0;
	 assign dot_b_pixel = dot_word[obj_x] ? 8'd255 : 8'd0;
	 
	 // read pill object image
	 logic [0:15]pill_word;
	 logic [7:0]pill_r_pixel, pill_g_pixel, pill_b_pixel;
	 pill_ROM pill (.address(obj_y), .clock(CLOCK_50), .q(pill_word));
	 assign pill_r_pixel = pill_word[obj_x] ? 8'd209 : 8'd0;
	 assign pill_g_pixel = pill_word[obj_x] ? 8'd57 : 8'd0;
	 assign pill_b_pixel = pill_word[obj_x] ? 8'd54 : 8'd0;
	 
	 // read ghost object image
	 logic [0:15]ghost_r_word, ghost_g_word, ghost_b_word;
	 logic [7:0]ghost_r_pixel, ghost_g_pixel, ghost_b_pixel;
	 ghost_R_ROM ghost_r (.address(obj_y), .clock(CLOCK_50), .q(ghost_r_word));
	 ghost_G_ROM ghost_g (.address(obj_y), .clock(CLOCK_50), .q(ghost_g_word));
	 ghost_B_ROM ghost_b (.address(obj_y), .clock(CLOCK_50), .q(ghost_b_word));
	 assign ghost_r_pixel = ghost_r_word[obj_x] ? 8'd255 : 8'd0;
	 assign ghost_g_pixel = ghost_g_word[obj_x] ? 8'd255 : 8'd0;
	 assign ghost_b_pixel = ghost_b_word[obj_x] ? 8'd209 : 8'd0;
		
    always_comb begin
		if (reset) begin
            r = 8'd0;
            g = 8'd0;
            b = 8'd0;
        end 
        else begin
            if (obj == 4'h1) begin
                r = wall_b_pixel;   
                g = wall_r_pixel;
                b = wall_g_pixel;
            end
            else if(obj == 4'h2) begin
                r = dot_r_pixel;
                g = dot_g_pixel;
                b = dot_b_pixel;
            end
            else if (obj == 4'h3) begin
                r = pill_r_pixel;
                g = pill_g_pixel;
                b = pill_b_pixel;
            end
            else if (obj == 4'h4) begin
                r = pacman_r_pixel;
                g = pacman_g_pixel;
                b = pacman_b_pixel;
            end
            else if (obj >= 4'h5) begin
                r = ghost_r_pixel;
                g = ghost_g_pixel;
                b = ghost_b_pixel;
            end
            else begin
                r = 8'd0;
                g = 8'd0;
                b = 8'd0;
            end 
        end
    end

endmodule

`timescale 1 ps / 1 ps
// testbench for VGA control module
module VGA_Ctrl_testbench();
    logic CLOCK_50, reset;
    logic [3:0] obj_x;
    logic [3:0] obj_y;
    logic [3:0] obj;
    logic [7:0] r, g, b;

    parameter CLOCK_PERIOD = 100;
    initial begin
        CLOCK_50 <= 0;
        forever #(CLOCK_PERIOD / 2) CLOCK_50 <= ~CLOCK_50;
    end

    VGA_Ctrl dut (.*);

    initial begin
        reset <= 1; @(posedge CLOCK_50);
        reset <= 0; @(posedge CLOCK_50);
        obj <= 1;
        for (int i = 0; i < 16; i++) begin
            for (int j = 0; j < 16; j++) begin
                obj_x <= i; obj_y <= j; @(posedge CLOCK_50);
            end
        end
        obj <= 2;
        for (int i = 0; i < 16; i++) begin
            for (int j = 0; j < 16; j++) begin
                obj_y <= i; obj_x <= j; @(posedge CLOCK_50);
            end
        end
        obj <= 3;
        for (int i = 0; i < 16; i++) begin
            for (int j = 0; j < 16; j++) begin
                obj_y <= i; obj_x <= j; @(posedge CLOCK_50);
            end
        end
        obj <= 4;
        for (int i = 0; i < 16; i++) begin
            for (int j = 0; j < 16; j++) begin
                obj_y <= i; obj_x <= j; @(posedge CLOCK_50);
            end
        end
        obj <= 5;
        for (int i = 0; i < 16; i++) begin
            for (int j = 0; j < 16; j++) begin
                obj_y <= i; obj_x <= j; @(posedge CLOCK_50);
            end
        end
        obj <= 6;
        for (int i = 0; i < 16; i++) begin
            for (int j = 0; j < 16; j++) begin
                obj_y <= i; obj_x <= j; @(posedge CLOCK_50);
            end
        end
        obj <= 7;
        for (int i = 0; i < 16; i++) begin
            for (int j = 0; j < 16; j++) begin
                obj_y <= i; obj_x <= j; @(posedge CLOCK_50);
            end
        end
		  $stop;
    end
endmodule

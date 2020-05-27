// EE 371 Lab 6 
// Winston Chen
// Connor Lowe
// This VGA control moduel would read from multiple ROM that stores the graphic design of Pacman game
// and output them to the VGA buffer
module VGA_Ctrl (CLOCK_50, reset, x, y, r, g, b);
    input logic CLOCK_50, reset;
    input logic [9:0] x;
    input logic [8:0] y;
    output logic [7:0] r, g, b;

    logic [5:0] glob_x, glob_y; 
    logic [159:0] map_word;
    logic [3:0] map_grid;
	 assign glob_x = x / 16;
    assign glob_y = y / 16;
	 map m (.clock(CLOCK_50), .data(), .rdaddress(glob_y), .rden(1), .wraddress(), .wren(0), .q(map_word)); 
    assign map_grid = map_word[4*glob_x+:3];
    
    logic [4:0] loc_y, loc_x;
    assign loc_y = y % 16;
    assign loc_x = x % 16;
    logic [127:0] wall_r_word, wall_g_word, wall_b_word;
    wall_ROM_r wall_R (.address(loc_y), .clock(CLOCK_50), .q(wall_r_word));
    wall_ROM_g wall_G (.address(loc_y), .clock(CLOCK_50), .q(wall_g_word));
    wall_ROM_b wall_B (.address(loc_y), .clock(CLOCK_50), .q(wall_b_word));

    logic [7:0] wall_r_pixel, wall_g_pixel, wall_b_pixel;
	assign wall_r_pixel = wall_r_word[16*loc_x+:15];
    assign wall_g_pixel = wall_g_word[16*loc_x+:15];
	assign wall_b_pixel = wall_b_word[16*loc_x+:15];
		
		
    always_comb begin
		if (reset) begin
            r = 8'd0;
            g = 8'd0;
            b = 8'd0;
        end 
        else begin
            if (map_grid == 4'd1) begin
                r = wall_b_pixel;   
                g = wall_r_pixel;
                b = wall_g_pixel;
            end
            else begin
                r = 8'd0;
                g = 8'd0;
                b = 8'd0;
            end
        end
    end


endmodule
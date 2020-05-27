// EE 371 Lab 6 
// Winston Chen
// Connor Lowe
// This is a ROM module that stores the graphic design of Wall object for packman game

module wall_ROM (x, y, r, g, b);
    input logic [3:0] x, y;
    output logic [7:0] r, g, b;

    logic ROM_R [0:15][0:127]; // each word: 16 * 8 read each
    logic ROM_G [0:15][0:127]; 
    logic ROM_B [0:15][0:127];  


    always_comb begin
        r = ROM_R[y][x:x+7];
        g = ROM_G[y][x:x+7];
        b = ROM_B[y][x:x+7];

    end

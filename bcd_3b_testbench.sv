// Winston Chen
// Connor Lowe
// 1573616
// 5/3/2020
// EE 371
// Lab 6
//
// This module tests the hexto7segment module with intent to utilize ModelSim.
// Varies input to ensure the out signals is sent as expected.
module bcd_3b_testbench();
    logic [9:0] binary;
    logic [3:0] hundreds;
    logic [3:0] tens;
    logic [3:0] ones;

	 // instantiation
    bcd_3b dut (.binary(binary), .hundreds(hundreds), .tens(tens), .ones(ones));
	 
	 // sets inputs to the design
    initial begin
        binary = 10'd255; #10;
        binary = 10'd121; #10;
        binary = 10'd333; #10;
    end
endmodule // closes module
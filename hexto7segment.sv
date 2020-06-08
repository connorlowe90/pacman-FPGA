// Connor Lowe
// Winston Chen
// 1573616
// 5/3/2020
// EE 371
// Lab 4
//
// This module encodes 7 segment displays. 
// This module inputs a 4 bit binary number and then outputs its corrosponding
//  one bit hex value graphicaly to the display.
// This is down by ouputting a 7 bit bus with intent to use a standard 7 segment display.
module hexto7segment(in, enable, out);
    input logic [3:0] in;   // 4 bit binary input
	 input logic enable;
    output logic [6:0] out; // output which corrosponds graphically to the hex value of in

	always_comb begin
		if (enable) begin
			case (in)
			4'b0000: out = 7'b1000000; // Hexadecimal 0
			4'b0001: out = 7'b1111001; // Hexadecimal 1
			4'b0010: out = 7'b0100100; // Hexadecimal 2
			4'b0011: out = 7'b0110000; // Hexadecimal 3
			4'b0100: out = 7'b0011001;	// Hexadecimal 4		
			4'b0101: out = 7'b0010010; // Hexadecimal 5	  
			4'b0110: out = 7'b0000010; // Hexadecimal 6		
			4'b0111: out = 7'b1111000; // Hexadecimal 7		
			4'b1000: out = 7'b0000000; // Hexadecimal 8		
			4'b1001: out = 7'b0010000; // Hexadecimal 9
			4'b1010: out = 7'b0001000; // Hexadecimal A
			4'b1011: out = 7'b0000011;	// Hexadecimal B		
			4'b1100: out = 7'b1000110;	// Hexadecimal C		
			4'b1101: out = 7'b0100001; // Hexadecimal D	
			4'b1110:	out = 7'b0000110;	// Hexadecimal E
			4'b1111:	out = 7'b0001110;	// Hexadecimal F
			endcase // closes the statement that assigns out based on in
			end // closes if enable
		else out = 7'b1111111; // default off
	end		  // closes the combination logic block
endmodule	  // closes the module that encodes for 7 segment displays 

// This module tests the hexto7segment module with intent to utilize ModelSim.
// Varies input to ensure the out signals is sent as expected.
module hexto7segment_testbench();
   logic [3:0] in;	// 4 bit binary input
	logic enable;
   logic [6:0] out; 	// output which corrosponds graphically to the hex value of in
	 
	// utilizing verilog's implicit port connection
	hexto7segment dut (.*);
	
	// Set up the inputs to the design.  Each line is a clock cycle.
   initial begin         
		in = 4'b0000; enable = 1;	#10; // test zero and on
											#10;
		in = 4'b1010; enable = 0;	#10; // test hex a and off
											#10;								
		$stop; // End the simulation. 
	end 		 // closes the block that sets inputs to the design
endmodule 	 // closes the module that tests hexto7segment
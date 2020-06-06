module testRomIns (address, clock, q);
	input	logic [15:0]  address;
	input	logic clock;
	output logic [7:0]  q;
	
	// utilizing verilog's implicit port connections
	testRom dut (.address(address), .clock(clock), .q(q));
endmodule 

`timescale 1 ps / 1 ps
module testRomIns_testbench();
	logic	[15:0]  address;
	logic	       clock;
	logic	[7:0]  q;
	
	// Set up the clock.   
	parameter CLOCK_PERIOD=100;  
	initial begin   
		clock <= 0;   
		forever #(CLOCK_PERIOD/2) clock <= ~clock; 
	end 
	
	// utilizing verilog's implicit port connections
   testRomIns dut(.*);
	
	// Set up the inputs to the design.  Each line is a clock cycle.
   initial begin         
		address = 5'b0000;  			@(posedge clock); 
											@(posedge clock); 
											@(posedge clock); 
		address = 5'b0010;  			@(posedge clock); 
											@(posedge clock);
											@(posedge clock);
		address = 5'b0000;			@(posedge clock);
											@(posedge clock);
											@(posedge clock);
											@(posedge clock);								
		$stop; // End the simulation. 
	end // closes the block that sets inputs to the design
endmodule // closes the module that tests ram32x4Ins
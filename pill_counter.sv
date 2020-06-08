module pill_counter (reset, collision_type, hex1, hex2, hex3);
	 input logic reset;
	 input logic [3:0] collision_type;
	 output logic [6:0] hex1, hex2, hex3;
	 
	 logic [9:0] pill_count;
	 logic [3:0] pc_ones, pc_tens, pc_hundreds;
	 bcd_3b bcd (.binary(pill_count), .hundreds(pc_hundreds), .tens(pc_tens), .ones(pc_ones));
	 // instantiate hex displays
	 hexto7segment hundreds  (.in(pc_hundreds), .enable(1'b1), .out(hex1));
	 hexto7segment tens  (.in(pc_tens), .enable(1'b1), .out(hex2));
	 hexto7segment ones  (.in(pc_ones), .enable(1'b1), .out(hex3));
	 
	 // combinational logic block outputting for hex displays the three bit
	 //  decimal number representing how many dots pacman has eaten.
	 always_latch begin
		if (reset) pill_count = 0;
		else if (collision_type == 4'b0010) pill_count = pill_count + 1;
		else pill_count = pill_count;
	 end // always_ff
	 
endmodule 

module pill_counter_testbench();
	logic reset;
	logic [3:0] collision_type;
	logic [6:0] hex1, hex2, hex3;
	
	// utilizing verilog's implicit port connection
	pill_counter dut (.*);
	
	// Set up the inputs to the design.  Each line is a clock cycle.
   initial begin     
		reset = 1; 		#10;
		reset = 0;   	#10; 
		collision_type = 4'b0010;  #10; // test zero and on
		collision_type = 4'b0110;  #10;
		collision_type = 4'b0010;  #10; // test hex a and off
											#10;								
		$stop; // End the simulation. 
	end 		 // closes the block that sets inputs to the design
endmodule 
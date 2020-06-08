module pill_counter (CLOCK_50, reset, collision_type, hex1, hex2, hex3);
	 input logic CLOCK_50, reset;
	 input logic [3:0] collision_type;
	 output logic [6:0] hex1, hex2, hex3;
	 
	 logic [9:0] pill_count;
	 logic [3:0] pc_ones, pc_tens, pc_hundreds;
	 
	 bcd_3b bcd (.binary(pill_count), .hundreds(pc_hundreds), .tens(pc_tens), .ones(pc_ones));
	 
	 // instantiate hex displays
	 hexto7segment hundreds  (.in(pc_hundreds), .enable(1'b1), .out(hex1));
	 hexto7segment tens      (.in(pc_tens), .enable(1'b1), .out(hex2));
	 hexto7segment ones      (.in(pc_ones), .enable(1'b1), .out(hex3));
	 
	 // combinational logic block outputting for hex displays the three bit
	 //  decimal number representing how many dots pacman has eaten.

	 enum {hold, incre} ps, ns;
	 always_comb begin
		 case (ps)
		 	hold: begin
				 if (collision_type == 4'b0010) begin
					 ns = incre;
				 end
				 else ns = hold;
			 end
			 incre: begin
				 ns = hold;
			 end
		 endcase
	 end

	 always_ff @(posedge CLOCK_50) begin
		 if (reset) begin
			 ps <= hold;
			 pill_count <= 0;
		 end
		 else begin
			 ps <= ns;
			 if (ps == incre) begin
				 pill_count += 1;
			 end
		 end
	 end
	 
endmodule 

module pill_counter_testbench();
	logic CLOCK_50, reset;
	logic [3:0] collision_type;
	logic [6:0] hex1, hex2, hex3;
	
	// utilizing verilog's implicit port connection
	pill_counter dut (.*);

	parameter CLOCK_PERIOD = 100;
    initial begin
        CLOCK_50 <= 0;
        forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
    end
	
	// Set up the inputs to the design.  Each line is a clock cycle.
   initial begin     
		reset = 1; collision_type = 4'b0000; @(posedge CLOCK_50);
		reset = 0;   	@(posedge CLOCK_50); 
		collision_type = 4'b0010;  @(posedge CLOCK_50); // test zero and on
								   @(posedge CLOCK_50);
		collision_type = 4'b0110;  @(posedge CLOCK_50);
								   @(posedge CLOCK_50);
		collision_type = 4'b0010;  @(posedge CLOCK_50);
								   @(posedge CLOCK_50); // test hex a and off
		collision_type = 4'b0010;  @(posedge CLOCK_50);
								   @(posedge CLOCK_50);
		collision_type = 4'b0010;  @(posedge CLOCK_50);
								   @(posedge CLOCK_50);
																		
		$stop; // End the simulation. 
	end 		 // closes the block that sets inputs to the design
endmodule 
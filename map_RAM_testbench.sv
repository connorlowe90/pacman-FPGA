// ram_map testbench
`timescale 1 ps / 1 ps
module map_RAM_testbench();
	logic [4:0] wraddr;
	logic clock, wren;
	logic [159:0] wrdata, redata;
	
	map_RAM m (.address_a(), .address_b(wraddr), .clock, .data_a(), .data_b(wrdata), .wren_a(0), .wren_b(wren), .q_a(), .q_b(redata));

	parameter CLOCK_PERIOD = 100;
   initial begin
       clock <= 0;
       forever #(CLOCK_PERIOD/2) clock <= ~clock;
   end

	initial begin
		wren <= 0; wrdata <= 159'bX; @(posedge clock);
		wraddr <= 5'd20; @(posedge clock);
						 @(posedge clock);
						 @(posedge clock);
						 @(posedge clock);
						 @(posedge clock);
	    wraddr <= 5'd13; @(posedge clock);
						 @(posedge clock);
						 @(posedge clock);
						 @(posedge clock);
		$stop;
	end
endmodule

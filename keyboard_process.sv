// Connor Lowe
// Winston Chen
// 1573616
// 5/3/2020
// EE 371
// Lab 6
//
// This module takes PS/2 keyboard input signal and out put
// up/down/left/right signal if corresponding keys are pushed
// Inputs clock, reset, and the makebrean and scan_code from given keyboard drivers.
module keyboard_process (CLOCK_50, reset, makeBreak, scan_code, up, down, left, right);
	input logic CLOCK_50, reset, makeBreak;
	input logic [7:0] scan_code;
	output logic up, down, left, right;

	enum {unpress, press, hold} ps, ns;

	// combinational logic block determining which key is pressed
	always_comb begin
		{up, down, left, right} = 4'd0;
		case(ps) 
			unpress: begin
				if (makeBreak) ns = press;
				else ns = unpress;
			end // closes unpress state
			press: begin
				if (makeBreak) ns = hold;
				else ns = unpress;
				if (scan_code == 8'h75) {up, down, left, right} = 4'b1000;
				else if (scan_code == 8'h6B) {up, down, left, right} = 4'b0010;
				else if (scan_code == 8'h72) {up, down, left, right} = 4'b0100;
				else if (scan_code == 8'h74) {up, down, left, right} = 4'b0001;
			end // closes press state
			hold: begin
				if (makeBreak) ns = hold;
				else ns = unpress;
			end // closes hold state
		endcase
	end // always_comb

	// sequential logic block determining next state
	always_ff @(posedge CLOCK_50) begin
		if (reset) begin
			ps <= unpress;
		end 
		else begin
			ps <= ns;
		end
	end // always_ff
	
endmodule // closes keyboard_process

// This module tests the keyboard_process module with intent to utilize ModelSim.
// Varies input to ensure the out signals is sent as expected.
module keyboard_process_testbench();
	logic CLOCK_50, reset, makeBreak;
	logic [7:0] scan_code;
	logic up, down, left, right;
	
	// utilizing verilog's implicit port connections
	keyboard_process dut (.*);
	
	// block that sets up the clock
	parameter CLOCK_PERIOD = 100;
    initial begin
        CLOCK_50 <= 0;
        forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
    end

	 // block that sets inputs for design
    initial begin
        reset = 1;          @(posedge CLOCK_50);
		  reset = 0;			 @(posedge CLOCK_50);
		  makeBreak = 1;      @(posedge CLOCK_50);
		  scan_code = 8'h75;  @(posedge CLOCK_50);
		  makeBreak = 0;      @(posedge CLOCK_50);
		  makeBreak = 1;      @(posedge CLOCK_50);
		  scan_code = 8'h74;  @(posedge CLOCK_50);
		  makeBreak = 0;      @(posedge CLOCK_50);
		  makeBreak = 1;      @(posedge CLOCK_50);
		  scan_code = 8'h6B;  @(posedge CLOCK_50);
		  makeBreak = 0;      @(posedge CLOCK_50);
		  makeBreak = 1;      @(posedge CLOCK_50);
		  scan_code = 8'h72;  @(posedge CLOCK_50);
		$stop;
    end // closes block setting inputs to design
endmodule // closes module testing pacman location control
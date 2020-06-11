// Connor Lowe
// Winston Chen
// 1573616
// 5/3/2020
// EE 371
// Lab 6
//
// This module outputs audio data given the audio codec modules
//  from EE371 at University of Washington, Seattle. 
// When the control signal chomp is asserted it plays an A7 tone for 
//  a quarter second. 
// This modules connects to various modules supplied by UW. 
module playAudio(chomp, eatghost, reset,
						CLOCK_50, 
						CLOCK2_50, 
						FPGA_I2C_SCLK, 
						FPGA_I2C_SDAT, 
						AUD_XCK, 
						AUD_DACLRCK, 
						AUD_ADCLRCK, 
						AUD_BCLK, 
						AUD_ADCDAT, 
						AUD_DACDAT);
	input logic reset;
	input logic chomp;
	input logic eatghost;
	input logic CLOCK_50, CLOCK2_50;
	input logic AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	input logic AUD_ADCDAT;
	inout logic FPGA_I2C_SDAT;
	output logic FPGA_I2C_SCLK;
	output logic AUD_DACDAT;
	output logic AUD_XCK;
	
	logic signed [23:0]  data, dataChomp;
	logic read_ready, read, write, write_ready;
	logic [23:0] readdata_left, readdata_right;
	logic [23:0] writedata_left, writedata_right;
	assign writedata_right = writedata_left;
	
	logic [23:0]readdata_leftout;
	logic [23:0]readdata_rightout;
	
	assign read = read_ready;			
	assign write = write_ready;
	
	logic [15:0]  address;
	
	// counter for length of tone
	logic clk_reset;
	parameter MAX = 12500000; // 50M reduce the ghost speed to 1Hz 
	parameter size = $clog2(MAX);
	logic [size-1:0] count2;
	counter2 #(MAX) cWait (.CLOCK_50(CLOCK_50), .reset(chomp), .count(count));
	
	// counter to generate tone
	parameter HALF_PERIOD = 7102;
	parameter size_c = $clog2(HALF_PERIOD);
	logic [size_c-1:0] cch_count;
	counter #(HALF_PERIOD) cchomp (.CLOCK_50(CLOCK_50), .reset(reset), .count(cch_count)); 
	 
	// if colliding then plat a tone
	assign writedata_left = (count > 0) ? dataChomp : 0;  
	
	// state variables
	enum {pos, neg} ps, ns;
	
	// combinational logic block that simulates wave
	always_comb begin
		case(ps)
			pos: begin
				if (cch_count == 0) ns = neg;
				else ns = pos;
				dataChomp = 40000;
			end
			neg: begin
				if (cch_count == 0) ns = pos;
				else ns = neg;
				dataChomp = -40000;
			end
		endcase
	end // always_comb
	
	// sequential logic block for next state
	always_ff @(posedge CLOCK_50) begin
	 if (reset) ps <= pos;
	 else ps <= ns;
	end // always_ff
	
	// given audio codec modules
	clock_generator my_clock_gen(
		CLOCK2_50,
		reset,
		AUD_XCK
	);

	audio_and_video_config cfg(
		CLOCK_50,
		reset,
		FPGA_I2C_SDAT,
		FPGA_I2C_SCLK
	);

	audio_codec codec(
		CLOCK_50,
		reset,
		read,	
		write,
		writedata_left, 
		writedata_right,
		AUD_ADCDAT,
		AUD_BCLK,
		AUD_ADCLRCK,
		AUD_DACLRCK,
		read_ready, write_ready,
		readdata_left, readdata_right,
		AUD_DACDAT
	);
	
endmodule // closes playAudio

// This module tests the playAudio module with intent to utilize ModelSim.
// Varies input to ensure the out signals is sent as expected.
`timescale 1 ps / 1 ps
module playAudio_testbench();
	logic start;
	logic reset;
	logic chomp;
	logic eatghost;
	logic death;
	logic CLOCK_50, CLOCK2_50;
	logic FPGA_I2C_SCLK;
	wire FPGA_I2C_SDAT;
	logic AUD_XCK;
	logic AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	logic AUD_ADCDAT;
	logic AUD_DACDAT;
	
	// utilizing verilog's implicit port connections
	playAudio dut (.*);
	
	// sets up the clock
	parameter CLOCK_PERIOD = 100;
	initial begin
        CLOCK_50 <= 0;
		  CLOCK2_50 <=0;
        forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
		  forever #(CLOCK_PERIOD/2) CLOCK2_50 <= ~CLOCK2_50;
    end // closes block setting up clock
	
	// block that sets inputs for the design
	initial begin
		reset = 1; 				    @(posedge CLOCK_50);
		reset = 0; 					 @(posedge CLOCK_50);
		chomp = 1;					 @(posedge CLOCK_50);
		chomp = 0; 					 @(posedge CLOCK_50);
		for(int i = 0; i < 1000000; i++) @(posedge CLOCK_50);
		$stop;
	end
endmodule // modules testing playAudio

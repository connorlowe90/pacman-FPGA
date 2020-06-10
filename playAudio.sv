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
	
	
	
//	parameter MAX = 50000; // 50M reduce the ghost speed to 1Hz 
//	parameter size = $clog2(MAX);
//	logic [size-1:0] count;
//	logic clk_reset;
//	logic incr;
//	counter3 #(MAX) c (.CLOCK_50(CLOCK_50), .reset(clk_reset), .incr(incr), .count(count));
	
	logic clk_reset;
	parameter MAX = 12500000; // 50M reduce the ghost speed to 1Hz 
	parameter size = $clog2(MAX);
	logic [size-1:0] count2;
	counter2 #(MAX) cWait (.CLOCK_50(CLOCK_50), .reset(chomp), .count(count));
	
	parameter HALF_PERIOD = 454545;
	parameter size_c = $clog2(HALF_PERIOD);
	logic [size_c-1:0] cch_count;
	counter #(HALF_PERIOD) cchomp (.CLOCK_50(CLOCK_50), .reset(reset), .count(cch_count)); 
	 
	assign writedata_left = (count > 0) ? dataChomp : 0;  
	
	enum {pos, neg} ps, ns;
	always_comb begin
		case(ps)
			pos: begin
				if (cch_count == 0) ns = neg;
				else ns = pos;
				dataChomp = 4000000;
			end
			neg: begin
				if (cch_count == 0) ns = pos;
				else ns = neg;
				dataChomp = -4000000;
			end
		endcase
	end
	
	always_ff @(posedge CLOCK_50) begin
	 if (reset) ps <= pos;
	 else ps <= ns;
	end
	
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
	
endmodule 

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
	
	playAudio dut (.*);
	
	parameter CLOCK_PERIOD = 100;
	initial begin
        CLOCK_50 <= 0;
		  CLOCK2_50 <=0;
        forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
		  forever #(CLOCK_PERIOD/2) CLOCK2_50 <= ~CLOCK2_50;
    end

	initial begin
		reset = 1; 				    @(posedge CLOCK_50);
		reset = 0; 					 @(posedge CLOCK_50);
		start = 1;					 @(posedge CLOCK_50);
		start = 0; 					 @(posedge CLOCK_50);
		for(int i = 0; i < 1000000; i++) @(posedge CLOCK_50);
		$stop;
	end
endmodule 

module playAudio(start, chomp, eatghost, death, reset,
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
	input logic start;
	input logic reset;
	input logic chomp;
	input logic eatghost;
	input logic death;
	input logic CLOCK_50, CLOCK2_50;
	output logic FPGA_I2C_SCLK;
	inout logic FPGA_I2C_SDAT;
	output logic AUD_XCK;
	input logic AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	input logic AUD_ADCDAT;
	output logic AUD_DACDAT;
	
	logic read_ready, read, write, write_ready;
	logic [23:0] readdata_left, readdata_right;
	logic [23:0] writedata_left, writedata_right;
	assign writedata_right = writedata_left;
	
	logic [23:0]readdata_leftout;
	logic [23:0]readdata_rightout;
	
	enum {hold, play_start, play_chomp, 
			play_eatghost, play_death} ps, ns;
	
	//assign writedata_left = (q)? readdata_leftout: 0;
	//assign writedata_right = (q)? readdata_rightout: 0;
	assign read = read_ready;			
	assign write = write_ready;
	
	logic [15:0]  address;
	logic [7:0]  data;
	
	// utilizing verilog's implicit port connections
	musicRom dut (.address(address), .clock(CLOCK_50), .q(data));
	
	parameter MAX = 50000; // 50M reduce the ghost speed to 1Hz 
	parameter size = $clog2(MAX);
	logic [size-1:0] count;
	logic clk_reset;
	logic incr;
	counter3 #(MAX) c (.CLOCK_50(CLOCK_50), .reset(clk_reset), .incr(incr), .count(count));
	
	parameter MAX2 = 4; // 50M reduce the ghost speed to 1Hz 
	parameter size2 = $clog2(MAX2);
	logic [size2-1:0] count2;
	counter #(MAX2) cWait (.CLOCK_50(CLOCK_50), .reset(reset), .count(count2));
	
	assign address = count;
	assign writedata_left = data;
	
	always_latch begin
		clk_reset = 0;
		incr = 0;
		case (ps) 
			hold: begin
				if (start) begin
					ns = play_start;
					clk_reset = 1;
					end
				else if (chomp) ns = play_chomp;
				else if (eatghost) ns = play_eatghost;
				else if (death) ns = play_death;
				else ns = hold;
				end
			play_start: begin
				if (count == MAX) ns = hold;
				else begin
					ns = play_start;
					end
				if (count2 == 0) incr = 1;
				else incr = 0;
				end
			play_chomp: begin
				
				
				end
			play_eatghost: begin
				
				
				end
			play_death: begin
			
				
				end
		endcase
		
	end
	
	always_ff @(posedge CLOCK_50) begin
	 if (reset) ps <= hold;
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
		for(int i = 0; i < 100000; i++) @(posedge CLOCK_50);
		$stop;
	end
endmodule 
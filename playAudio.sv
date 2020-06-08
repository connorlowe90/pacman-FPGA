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
	input CLOCK_50, CLOCK2_50;
	output FPGA_I2C_SCLK;
	inout FPGA_I2C_SDAT;
	output AUD_XCK;
	input AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	input AUD_ADCDAT;
	output AUD_DACDAT;
	
	logic read_ready, read, write;
	logic [23:0] readdata_left, readdata_right;
	logic [23:0] writedata_left, writedata_right;
	
	logic [23:0]readdata_leftout;
	logic [23:0]readdata_rightout;
	
	assign writedata_left = (write_ready&write_ready)? readdata_leftout: 0;
	assign writedata_right = (write_ready&write_ready)? readdata_rightout: 0;
	assign read = read_ready;			
	assign write = write_ready;
	
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
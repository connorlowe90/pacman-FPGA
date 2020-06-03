// This is a counter module that counts from user defined number to 0
module counter #(parameter MAX = 50000000)(CLOCK_50, reset, count);
    parameter size = $clog2(MAX);
    input logic CLOCK_50, reset;
    output logic [size-1:0] count;

    always_ff @(posedge CLOCK_50) begin
        if (reset) begin
            count <= MAX;
        end 
        else begin
            if (count > 0) count <= count - 1;
            else count <= count;
        end
    end
endmodule

// This is the test module for the counter
module counter_testbench();
	 
	 parameter MAX = 10;
	 parameter size = $clog2(MAX);
    logic CLOCK_50, reset;
    logic [size-1:0] count;
    
	 
    counter #(MAX) dut (.*);

    parameter CLOCK_PERIOD = 100;
    initial begin
        CLOCK_50 <= 0;
        forever #(CLOCK_PERIOD / 2) CLOCK_50 <= ~CLOCK_50;
    end

    initial begin
        reset <= 1; @(posedge CLOCK_50);
        reset <= 0; @(posedge CLOCK_50);
                    @(posedge CLOCK_50);
                    @(posedge CLOCK_50);
                    @(posedge CLOCK_50);
                    @(posedge CLOCK_50);
                    @(posedge CLOCK_50);
                    @(posedge CLOCK_50);
                    @(posedge CLOCK_50);
                    @(posedge CLOCK_50);
                    @(posedge CLOCK_50);
                    @(posedge CLOCK_50);
                    @(posedge CLOCK_50);
                    @(posedge CLOCK_50);
                    @(posedge CLOCK_50);
                    @(posedge CLOCK_50);
                    @(posedge CLOCK_50);
                    @(posedge CLOCK_50);
                    @(posedge CLOCK_50);
        $stop;
    end
endmodule
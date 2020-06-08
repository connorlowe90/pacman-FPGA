// This is a counter module that counts from user defined number to 0
module counter3 #(parameter MAX = 50000000)(CLOCK_50, reset, incr, count);
    parameter size = $clog2(MAX);
    input logic CLOCK_50, reset, incr;
    output logic [size-1:0] count;

    always_ff @(posedge CLOCK_50) begin
        if (reset) begin
            count <= 0;
        end 
        else begin
            if (count == MAX) count <= count;
            else if (incr) count <= count + 1;
        end
    end
endmodule

// This is the test module for the counter
module counter3_testbench();
	 
	 parameter MAX = 10;
	 parameter size = $clog2(MAX);
    logic CLOCK_50, reset, incr;
    logic [size-1:0] count;
    
	 
    counter3 #(MAX) dut (.*);

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
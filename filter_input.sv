// This module filters the user input into only high for one clock cycle
module filter_input (CLOCK_50, reset, in, out);
    input logic CLOCK_50, reset, in;
    output logic out;

    enum {init, high, hold} ps, ns;

    always_comb begin
        case(ps)
            init: begin
                if (in) ns = high;
                else ns = init;
            end
            high: begin
                if (in) ns = hold;
                else ns = init;
            end
            hold: begin
                if (in) ns = hold;
                else ns = init;
            end
        endcase
    end
    assign out = (ps == high);
    always_ff @(posedge CLOCK_50) begin
        if (reset) ps <= init;
        else ps <= ns;
    end
endmodule

// testbench
module filter_input_testbench();
    logic CLOCK_50, reset, in;
    logic out;

    filter_input dut (.*);

    parameter CLOCK_PERIOD = 100;
    initial begin
        CLOCK_50 <= 0;
        forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
    end

    initial begin
        reset <= 1; @(posedge CLOCK_50);
        reset <= 0; @(posedge CLOCK_50);
        in <= 0; @(posedge CLOCK_50);
        in <= 1; @(posedge CLOCK_50);
                 @(posedge CLOCK_50);
                 @(posedge CLOCK_50);
                 @(posedge CLOCK_50);
                 @(posedge CLOCK_50);
                 @(posedge CLOCK_50);
        in <= 0; @(posedge CLOCK_50);
        in <= 1; @(posedge CLOCK_50);
                 @(posedge CLOCK_50);
                 @(posedge CLOCK_50);
        $stop; 
    end
endmodule

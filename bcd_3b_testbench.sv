// testmodule for bcd_3b
module bcd_3b_testbench();
    logic [7:0] binary;
    logic [3:0] hundreds;
    logic [3:0] tens;
    logic [3:0] ones;

    bcd_3b dut (.binary(binary), .hundreds(hundreds), .tens(tens), .ones(ones));
	 
    initial begin
        binary = 8'd255; #10;
        binary = 8'd121; #10;
    end
endmodule
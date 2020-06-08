// testmodule for bcd_3b
module bcd_3b_testbench();
    logic [8:0] binary;
    logic [3:0] hundreds;
    logic [3:0] tens;
    logic [3:0] ones;

    bcd_3b dut (.binary(binary), .hundreds(hundreds), .tens(tens), .ones(ones));
	 
    initial begin
        binary = 9'd255; #10;
        binary = 9'd121; #10;
        binary = 9'd333;
    end
endmodule
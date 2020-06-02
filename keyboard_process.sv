// This module takes PS/2 keyboard input signal and out put
// up/down/left/right signal if corresponding keys are pushed

module keyboard_process (CLOCK_50, reset, makeBreak, scan_code, up, down, left, right);
	input logic CLOCK_50, reset, makeBreak;
	input logic [7:0] scan_code;
	output logic up, down, left, right;

	enum {unpress, press, hold} ps, ns;

	always_comb begin
		{up, down, left, right} = 4'd0;
		case(ps) 
			unpress: begin
				if (makeBreak) ns = press;
				else ns = unpress;
			end
			press: begin
				if (makeBreak) ns = hold;
				else ns = unpress;
				if (scan_code == 8'h75) {up, down, left, right} = 4'b1000;
				else if (scan_code == 8'h6B) {up, down, left, right} = 4'b0010;
				else if (scan_code == 8'h72) {up, down, left, right} = 4'b0100;
				else if (scan_code == 8'h74) {up, down, left, right} = 4'b0001;
			end
			hold: begin
				if (makeBreak) ns = hold;
				else ns = unpress;
			end
		endcase
	end

	always_ff @(posedge CLOCK_50) begin
		if (reset) begin
			ps <= unpress;
		end 
		else begin
			ps <= ns;
		end
	end
endmodule


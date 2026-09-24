module dffsr2(clk, preset, clear, d, q);
input clk, preset, clear, d;
output q;
wire clk, preset, clear, d;
dffsr2_sub uut (clk, preset && !clear, !preset && clear, d, q);
endmodule

(* gentb_skip *)
module dffsr2_sub(clk, preset, clear, d, q);
input clk, preset, clear, d;
output reg q;
always @(posedge clk, posedge preset, posedge clear) begin
	if (preset)
		q <= 1;
	else if (clear)
		q <= 0;
	else
		q <= d;
end
endmodule

// § vlogEnumBaseKwSpan235
module top(input clk, output [3:0] o);
  enum logic [3:0] {S0, S1=4'd3, S2} st;
  always @(posedge clk) st <= S1;
  assign o = st;
endmodule

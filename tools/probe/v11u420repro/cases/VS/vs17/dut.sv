// § assertBinParenSpanInner420
module top(input logic clk, clk2, rst, a, b, c, d, input logic [3:0] v);
  property p; @(posedge clk) ((a ##1 b) or (c ##1 d)) |-> v[2]; endproperty
  assert property (p);
endmodule

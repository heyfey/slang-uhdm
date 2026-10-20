// § seqAndOrLogOp420
module top(input logic clk, clk2, rst, a, b, c, d, input logic [3:0] v);
  sequence s1; a ##1 b; endsequence
  sequence s2; c ##1 d; endsequence
  property p; @(posedge clk) s1 and s2; endproperty
  assert property (p);
endmodule

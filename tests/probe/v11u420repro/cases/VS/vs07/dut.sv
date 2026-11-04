// § seqLeadDelayPairUnary420
module top(input logic clk, clk2, rst, a, b, c, d, input logic [3:0] v);
  property p; @(posedge clk) ##2 a ##1 b; endproperty
  assert property (p);
endmodule

// § seqLeadDelayPairUnary420
module top(input logic clk, clk2, en, rst, a, b, c, d, input logic [3:0] v);
  property p; @(posedge clk) ##1 a ##1 b |-> c; endproperty
  assert property (p);
endmodule

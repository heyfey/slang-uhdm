// § seqLeadDelayPairUnary420
module top(input logic clk, clk2, rst, a, b, c, d, input logic [3:0] v);
  property p; @(posedge clk) ##[1:3] a ##[0:2] b; endproperty
  assert property (p);
endmodule

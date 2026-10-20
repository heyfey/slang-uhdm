// § seqLeadDelayPairUnary420
module top(input logic clk, clk2, rst, a, b, c, d, input logic [3:0] v);
  sequence s; ##1 a ##1 b; endsequence
  assert property (@(posedge clk) s);
endmodule

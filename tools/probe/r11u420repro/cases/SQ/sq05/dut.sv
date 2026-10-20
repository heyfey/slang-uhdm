// § seqLeadDelayPairUnary420
module top;
  logic clk, clk2, a, b;
  sequence s;
    @(posedge clk) ##[1:3] a ##1 b;
  endsequence
  assert property (s);
endmodule

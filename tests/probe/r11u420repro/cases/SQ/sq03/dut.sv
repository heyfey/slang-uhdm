// § seqLeadDelayPairUnary420
module top;
  logic clk, clk2, a, b;
  sequence s;
    @(posedge clk) ##1 a ##1 @(posedge clk2) b;
  endsequence
  assert property (s);
endmodule

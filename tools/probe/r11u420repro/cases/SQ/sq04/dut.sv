// § seqLeadDelayPairUnary420
module top;
  logic clk, clk2, a, b;
  sequence s;
    @(posedge clk) ##2 a;
  endsequence
  assert property (s);
endmodule

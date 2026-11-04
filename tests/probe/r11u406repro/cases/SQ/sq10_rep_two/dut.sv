// § seqConcatNestsRight406
module top;
  logic clk, a, b, c, d;
  sequence s;
    @(posedge clk) b ##1 a [->2] ##1 b ##1 c [=1] ##1 d;
  endsequence
  assert property (s);
endmodule

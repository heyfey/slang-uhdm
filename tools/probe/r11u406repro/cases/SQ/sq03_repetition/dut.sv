// § seqConcatNestsRight406
module top;
  logic clk, a, b;
  sequence seq;
    @(posedge clk) b ##1 a [*2:10] ##1 b;
  endsequence
  assert property (seq);
endmodule

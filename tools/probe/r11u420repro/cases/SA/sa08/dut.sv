// § seqAndOrLogOp420
module top;
  logic clk, a, b, c, d, e;
  sequence s;
    @(posedge clk) (a and b) ##1 e;
  endsequence
  assert property (s);
endmodule

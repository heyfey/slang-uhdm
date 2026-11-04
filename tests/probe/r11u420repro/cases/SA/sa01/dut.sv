// § seqAndOrLogOp420
module top;
  logic clk, a, b, c, d, e;
  sequence s;
    @(posedge clk) ((a ##1 b) and (c ##2 d)) ##0 e;
  endsequence
  assert property (s);
endmodule

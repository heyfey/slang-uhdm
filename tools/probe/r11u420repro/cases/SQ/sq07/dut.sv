// § clockedSeqEventSpanBare420
module top;
  logic clk, clk2, a, b, c;
  logic [1:0] v;
  sequence s;
    @(posedge clk) a ##1 @(posedge clk2) b ##1 c;
  endsequence
  assert property (s);
endmodule

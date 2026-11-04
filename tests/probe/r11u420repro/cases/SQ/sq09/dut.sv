// § clockedSeqEventSpanBare420
module top;
  logic clk, clk2, a, b, c;
  logic [1:0] v;
  sequence s;
    @(posedge clk) a ##1 @(negedge clk2) v[1];
  endsequence
  assert property (s);
endmodule

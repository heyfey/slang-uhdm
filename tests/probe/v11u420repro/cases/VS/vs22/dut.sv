// § clockedSeqEventSpanBare420
module top(input logic clk, clk2, rst, a, b, c, d, input logic [3:0] v);
  sequence s(x, y); @(posedge clk) x ##1 @(clk2) y; endsequence
  assert property (s(a, b));
endmodule

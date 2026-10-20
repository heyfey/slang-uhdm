// § clockedSeqEventSpanBare420
module top(input logic clk, clk2, en, rst, a, b, c, d, input logic [3:0] v);
  property p; @(posedge clk) a ##1 @(posedge clk2 iff en) b; endproperty
  assert property (p);
endmodule

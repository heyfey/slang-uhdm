// § clockedSeqEventSpanBare420
module top(input logic clk, clk2, rst, a, b, c, d, input logic [3:0] v);
  property p; @(posedge clk) a |=> @(posedge clk2) (b and c); endproperty
  assert property (p);
endmodule

// § clockedSeqEventSpanBare420
module top(input logic clk, clk2, rst, a, b, c, d, input logic [3:0] v);
  property p; @(posedge clk) a ##1 @(posedge clk2) v[1:0] == 2'b01; endproperty
  assert property (p);
endmodule

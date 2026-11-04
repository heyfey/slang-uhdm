// § seqAndOrLogOp420
module top(input logic clk, clk2, rst, a, b, c, d, input logic [3:0] v);
  property p; @(posedge clk) (a ##1 b) and (c ##[1:2] d); endproperty
  assert property (p);
endmodule

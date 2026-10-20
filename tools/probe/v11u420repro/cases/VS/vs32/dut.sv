// § seqAndOrLogOp420
module top(input logic clk, clk2, en, rst, a, b, c, d, input logic [3:0] v);
  property p; @(posedge clk) first_match(a ##[1:2] b) or c; endproperty
  assert property (p);
endmodule

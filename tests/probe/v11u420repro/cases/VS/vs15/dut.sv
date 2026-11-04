// § propAndOrUnparented420
module top(input logic clk, clk2, rst, a, b, c, d, input logic [3:0] v);
  property p(x, y); @(posedge clk) (x |-> y) or (y |-> x); endproperty
  assert property (p(a, b));
endmodule

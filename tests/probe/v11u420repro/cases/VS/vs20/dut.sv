// § propAndOrUnparented420
module top(input logic clk, clk2, rst, a, b, c, d, input logic [3:0] v);
  property p; @(posedge clk) (a |-> b) and c; endproperty
  assert property (p);
endmodule

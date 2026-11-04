// § propAndOrUnparented420
module top;
  logic clk, a, b;
  property p(x, y);
    @(posedge clk) (x |-> y) and (y |-> x);
  endproperty
  assert property (p(a, b));
endmodule

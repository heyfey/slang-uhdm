// § propAndOrUnparented420
module top;
  logic clk, a, b, c, d, e;
  property p;
    @(posedge clk) ((a |-> b) or (c |-> d));
  endproperty
  assert property (p);
endmodule

// § propAndOrUnparented420
module top;
  logic clk, a, b, c, d, e;
  logic [1:0] v;
  property p;
    @(posedge clk) (a |-> b) or (c ##1 d);
  endproperty
  assert property (p);
endmodule

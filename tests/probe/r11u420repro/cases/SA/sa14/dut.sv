// § propAndOrUnparented420
module top;
  logic clk, a, b, c, d, e;
  logic [1:0] v;
  property p;
    @(posedge clk) (a |-> v[0]) and (c |=> d);
  endproperty
  assert property (p);
endmodule

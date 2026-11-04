// § assertLocalVarImplicitNet407
module top(input logic clk, input logic v, input logic [7:0] in, input logic [7:0] out);
  property p;
    int x;
    @(posedge clk) (v, x = in) |-> ##1 (out == x);
  endproperty
  assert property (p);
endmodule

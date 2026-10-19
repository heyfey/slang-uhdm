// § assertLocalVarImplicitNet407
program prg(input logic clk, input logic v, input logic [7:0] in, input logic [7:0] out);
  property prop;
    int x;
    @(posedge clk) (v, x = in) |-> ##1 (out == x);
  endproperty
  assert property (prop);
endprogram
module top(input logic clk, input logic v, input logic [7:0] in, input logic [7:0] out);
  prg p(clk, v, in, out);
endmodule

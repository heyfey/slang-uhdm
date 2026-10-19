// § assertLocalVarImplicitNet407
interface ifc(input logic clk, input logic v, input logic [7:0] in, input logic [7:0] out);
  sequence seq;
    int x;
    @(posedge clk) (v, x = in) ##1 (out == x);
  endsequence
  assert property (seq);
endinterface
module top(input logic clk, input logic v, input logic [7:0] in, input logic [7:0] out);
  ifc i(clk, v, in, out);
endmodule

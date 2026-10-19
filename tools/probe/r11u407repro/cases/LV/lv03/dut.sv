// § assertLocalVarImplicitNet407
module top(input logic clk, input logic v, input logic [7:0] in, input logic [7:0] out);
  sequence s1;
    int x;
    @(posedge clk) (v, x = in) ##1 (out == x);
  endsequence
  sequence s2;
    int x;
    @(posedge clk) (v, x = out) ##1 (in == x);
  endsequence
  assert property (s1);
  assert property (s2);
endmodule

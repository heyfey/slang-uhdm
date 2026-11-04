// § assertLocalVarImplicitNet407
module top(input logic clk, input logic v, input logic [7:0] in, input logic [7:0] out);
  sequence seq(a);
    int x;
    @(posedge clk) (a, x = in) ##1 (out == x);
  endsequence
  sequence seq2;
    int y;
    @(posedge clk) (v, y = in) ##1 (out != y);
  endsequence
  assert property (seq(v));
  cover property (seq2);
endmodule

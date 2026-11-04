// § assertLocalVarImplicitNet407
module top(input logic clk, input logic v, input logic [7:0] in, input logic [7:0] out);
  int x;
  sequence seq;
    int x;
    @(posedge clk) (v, x = in) ##1 (out == x);
  endsequence
  assert property (seq);
  initial x = 3;
endmodule

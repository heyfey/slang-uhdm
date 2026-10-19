// § assertLocalVarImplicitNet407
module sub(input logic clk, input logic v, input logic [7:0] in, input logic [7:0] out);
  sequence seq;
    int x;
    @(posedge clk) (v, x = in) ##1 (out == x);
  endsequence
  assert property (seq);
endmodule
module top(input logic clk, input logic v, input logic [7:0] in, input logic [7:0] out);
  sequence seq;
    byte x;
    @(posedge clk) (v, x = in) ##1 (out != x);
  endsequence
  cover property (seq);
  sub u(clk, v, in, out);
endmodule

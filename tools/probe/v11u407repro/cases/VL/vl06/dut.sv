// § assertLocalVarImplicitNet407
program prg(input logic clk, input logic v, input logic [7:0] in, input logic [7:0] out);
  sequence seq;
    int x;
    @(posedge clk) (v, x = in) ##1 (out == x);
  endsequence
  assert property (seq);
endprogram
module top(input logic clk, input logic v, input logic [7:0] in, input logic [7:0] out);
  prg p(clk, v, in, out);
endmodule

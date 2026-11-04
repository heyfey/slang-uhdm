// § assertLocalVarImplicitNet407
module top(input logic clk, input logic v, input logic [7:0] in, input logic [7:0] out);
  sequence seq;
    int x;
    @(posedge clk) (v, x = in) ##2 (out == x + 2);
  endsequence
  assert property (seq);
endmodule

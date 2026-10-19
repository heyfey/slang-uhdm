// § assertLocalVarImplicitNet407
module top(input logic clk, input logic v, input logic [7:0] in, input logic [7:0] out);
  struct packed { logic [3:0] a; logic [3:0] b; } x;
  sequence seq;
    int x;
    @(posedge clk) (v, x = in) ##1 (out == x);
  endsequence
  assert property (seq);
endmodule

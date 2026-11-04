// § assertLocalVarImplicitNet407
module top(input logic clk, input logic v, input logic [7:0] in, input logic [7:0] out);
  sequence seq;
    logic [7:0] x;
    @(posedge clk) (v, x = in) ##1 (out == x) ##1 (out == x + 1);
  endsequence
  always @(posedge clk) assert property (seq);
endmodule

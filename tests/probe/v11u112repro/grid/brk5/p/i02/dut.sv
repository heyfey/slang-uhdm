module m(input logic clk, rst, a, b);
  a1: assert property (@(posedge clk) (a ##1 b) or (b ##1 a));
endmodule

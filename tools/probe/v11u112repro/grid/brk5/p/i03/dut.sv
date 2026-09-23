module m(input logic clk, rst, a, b);
  a1: assert property (@(posedge clk) a |-> ##1 b ##2 a);
endmodule

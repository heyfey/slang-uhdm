module m(input logic clk, rst, a, b);
  a1: assert property (@(posedge clk) (a and b) |=> not a);
endmodule

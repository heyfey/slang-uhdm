module m(input logic clk, rst, a, b);
  a1: assert property (@(posedge clk) disable iff (rst) a |-> b);
endmodule

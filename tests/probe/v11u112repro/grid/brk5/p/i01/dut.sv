module m(input logic clk, rst, a, b);
  a1: assert property (@(posedge clk) s_eventually b);
endmodule

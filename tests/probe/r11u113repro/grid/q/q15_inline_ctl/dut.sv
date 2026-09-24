module m(input logic clk, rst, a, b, c);
  a1: assert property (@(posedge clk) a |-> b[*1:3]);
endmodule

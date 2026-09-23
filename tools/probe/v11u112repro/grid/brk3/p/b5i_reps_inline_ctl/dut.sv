module m(input logic clk, rst, a, b);
  a2: assert property (@(posedge clk) a |-> b[*1:3]);
endmodule

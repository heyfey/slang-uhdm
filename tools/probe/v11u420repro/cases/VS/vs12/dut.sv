// § seqAndOrLogOp420
module top(input logic clk, clk2, rst, a, b, c, d, input logic [3:0] v);
  cover property (@(posedge clk) a and b);
endmodule

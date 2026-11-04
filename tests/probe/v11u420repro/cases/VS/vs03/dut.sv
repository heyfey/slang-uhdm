// § seqAndOrLogOp420
module top(input logic clk, clk2, rst, a, b, c, d, input logic [3:0] v);
  sequence s; a and b; endsequence
  assert property (@(posedge clk) s);
endmodule

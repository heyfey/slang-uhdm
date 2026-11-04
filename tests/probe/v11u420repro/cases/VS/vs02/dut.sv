// § seqAndOrLogOp420
module top(input logic clk, clk2, rst, a, b, c, d, input logic [3:0] v);
  assert property (@(posedge clk) a ##1 b or c ##1 d);
endmodule

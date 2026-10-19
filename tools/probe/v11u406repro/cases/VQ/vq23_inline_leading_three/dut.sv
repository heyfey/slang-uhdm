// § seqConcatNestsRight406
module top(input logic clk, input logic a, input logic b, input logic c, input logic d);
  assert property (@(posedge clk) a |-> ##2 b ##1 c ##1 d);
endmodule

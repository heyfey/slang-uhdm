// § seqConcatNestsRight406
module top(input logic clk, input logic a, input logic b, input logic c, input logic d);
  sequence s;
    (a ##1 b ##1 c) or (d ##1 a);
  endsequence
  assert property (@(posedge clk) s);
endmodule

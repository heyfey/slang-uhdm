// § seqConcatNestsRight406
module top(input logic clk, input logic a, input logic b, input logic c, input logic d);
  sequence s;
    a ##0 b ##1 c ##2 d;
  endsequence
  cover property (@(posedge clk) s);
endmodule

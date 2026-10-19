// § seqConcatNestsRight406
module top(input logic clk, input logic a, input logic b, input logic c, input logic d);
  sequence s;
    a throughout (b ##1 c ##1 d);
  endsequence
  assert property (@(posedge clk) s);
endmodule

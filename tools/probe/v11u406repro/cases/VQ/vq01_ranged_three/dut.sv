// § seqNestRangedDelay406v
module top(input logic clk, input logic a, input logic b, input logic c);
  sequence s;
    a ##[1:2] b ##1 c;
  endsequence
  assert property (@(posedge clk) s);
endmodule

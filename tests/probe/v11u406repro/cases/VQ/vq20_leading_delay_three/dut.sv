// § seqNestLeadingDelay406v
module top(input logic clk, input logic a, input logic b, input logic c);
  sequence s;
    ##1 a ##1 b ##1 c;
  endsequence
  assert property (@(posedge clk) s);
endmodule

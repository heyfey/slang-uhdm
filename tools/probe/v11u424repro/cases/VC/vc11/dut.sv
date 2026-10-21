// § coverClockedPropExprIsClock424
module top(input bit clk, input a, input b);
  sequence s; @(posedge clk) a ##1 b; endsequence
  cover sequence (s);
  cover property (@(posedge clk) s);
endmodule

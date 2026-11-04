// § coverClockedPropExprIsClock424
module top(input bit clk, input rst, input a, input b);
  cover property (@(posedge clk) disable iff (rst) a ##1 b);
endmodule

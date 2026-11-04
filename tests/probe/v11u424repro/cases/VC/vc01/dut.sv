// § coverClockedPropExprIsClock424
module top(input bit clk, input a, input b);
  default clocking cb @(posedge clk); endclocking
  cover property (a ##1 b) $display("hit");
endmodule

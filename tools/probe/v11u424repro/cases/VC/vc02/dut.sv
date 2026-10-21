// § coverClockedPropExprIsClock424
module top(input bit clk, input a, input b);
  restrict property (@(posedge clk) a |-> b);
endmodule

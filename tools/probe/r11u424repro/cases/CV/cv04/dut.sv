// § coverClockedPropExprIsClock424
module top(input bit clk, input read, input write);
  cover sequence (read ##1 write);
endmodule

// § coverClockedPropExprIsClock424
module top(input bit clk, input read, input write);
  cover property (@(posedge clk) read);
endmodule

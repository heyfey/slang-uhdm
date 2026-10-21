// § coverClockedPropExprIsClock424
module top(input bit clk, input read, input write);
  cover property (read);
  cover sequence (@(posedge clk) read ##1 write);
  restrict property (@(posedge clk) read);
endmodule

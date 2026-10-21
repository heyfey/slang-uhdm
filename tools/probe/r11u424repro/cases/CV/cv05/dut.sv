// § coverClockedPropExprIsClock424
module top(input bit clk, input read, input write);
  cover property (@(posedge clk) disable iff (write) read);
  cover sequence (@(posedge clk) disable iff (write) read ##1 write);
endmodule

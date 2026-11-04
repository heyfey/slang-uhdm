// § coverClockedPropExprIsClock424
module top(input bit clk, input a, input b);
  cover sequence (@(posedge clk) a ##1 b) $display("seq");
endmodule

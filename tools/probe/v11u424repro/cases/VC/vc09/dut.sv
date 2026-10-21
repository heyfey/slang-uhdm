// § coverClockedPropExprIsClock424
module top(input bit clk, input a, input b);
  cover property (@(posedge clk) a) begin $display("1"); $display("2"); end
endmodule

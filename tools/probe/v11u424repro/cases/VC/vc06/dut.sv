// § coverClockedPropExprIsClock424
module top(input bit clk, input a, input b);
  assert property (@(posedge clk) a |-> b) $display("p"); else $display("f");
  cover property (@(negedge clk) b);
endmodule

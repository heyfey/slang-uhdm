// § coverClockedPropExprIsClock424
module top(input bit clk, input a, input b);
  if (1) begin : g
    cover property (@(posedge clk) a) $display("g");
  end
endmodule

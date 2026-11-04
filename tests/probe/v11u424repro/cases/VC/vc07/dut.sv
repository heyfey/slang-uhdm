// § coverClockedPropExprIsClock424
module top(input bit clk, input a);
  always @(posedge clk) begin
    cover property (a);
  end
endmodule

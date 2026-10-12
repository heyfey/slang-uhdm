// § delayParenInnerExprSpan292
module top;
  parameter int P = 2;
  logic clk;
  initial begin
    #( P ) clk = 0;
    # /*c*/ ( P * 2 ) clk = 1;
    #(
      5
    ) clk = 0;
    clk = #( 3 ) 1;
  end
  always #( P ) clk = ~clk;
endmodule

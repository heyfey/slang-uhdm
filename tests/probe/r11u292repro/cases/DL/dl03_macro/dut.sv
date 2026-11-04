// § delayParenInnerExprSpan292
`define DLY(v) #( v )
module top;
  parameter int P = 2;
  logic clk;
  initial begin
    `DLY(P) clk = 0;
    #(P) clk = 1;
  end
endmodule

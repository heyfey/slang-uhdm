// § delayParenInnerExprSpan292
module top;
  parameter int P = 2;
  logic clk;
  initial begin
    #((P)) clk = 0;
    #( (P + 1) ) clk = 1;
    #(P:P+1:P+2) clk = 0;
    #( P ) ;
  end
endmodule

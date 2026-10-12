// § delayParenInnerExprSpan292
module top;
  parameter int P = 1;
  assign #( P ) w = 1'b1;
  initial #( P
  ) ;
endmodule

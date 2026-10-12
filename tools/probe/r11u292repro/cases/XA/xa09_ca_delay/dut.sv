// § delayParenInnerExprSpan292
module top(output wire w, output wire v);
  parameter int P = 1;
  assign #( P ) w = 1'b1;
  assign #(
    P + 1 ) v = 1'b0;
  initial #( P
  ) ;
endmodule

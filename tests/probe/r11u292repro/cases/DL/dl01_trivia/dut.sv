// § delayParenInnerExprSpan292
module top;
  parameter time P = 2;
  int x;
  task automatic run;
    # (P) x = 1;
    #(
      P + 2
    ) x = 3;
    #/*between*/(P + 3) x = 4;
    #( /*inner*/ P + 4 /*tail*/ ) x = 5;
    #(  P  ) x = 6;
    x <= # (P) 6;
    x <= #/*between*/(P + 1) 7;
    x <= #(  P + 2  ) 8;
  endtask
endmodule

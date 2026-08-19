// r10v100: legal trivia between the pound, parens, and expression.
module v100_b3;
  parameter time P = 2;
  int x;
  task automatic run;
    # (P) x = 1;
    #      (P + 1) x = 2;
    #(
      P + 2
    ) x = 3;
    #/*between*/(P + 3) x = 4;
    #( /*inner*/ P + 4 /*tail*/ ) x = 5;
    x <= # (P) 6;
    x <= #/*between*/(P + 1) 7;
  endtask
endmodule

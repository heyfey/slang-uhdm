// § paramFoldParenSpan131
module a #(parameter W = (1 + 1)) (); endmodule
module b #(parameter W = 2) (); endmodule
module top ();
  a ua();
  b ub();
endmodule

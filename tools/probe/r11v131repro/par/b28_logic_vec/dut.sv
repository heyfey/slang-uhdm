// § paramFoldParenSpan131
module sub #(parameter logic [7:0] W = (8'h3 | 8'h10)) ();
endmodule
module top ();
  sub u();
endmodule

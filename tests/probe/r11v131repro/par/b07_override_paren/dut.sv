// § paramFoldParenSpan131
module sub #(parameter W = (2 + 2)) ();
endmodule
module top ();
  sub #(.W((5 + 1))) u();
endmodule

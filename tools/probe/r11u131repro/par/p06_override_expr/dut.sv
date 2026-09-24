// § paramFoldParenSpan131
module sub #(parameter W = (8), parameter D = (W-1)) ();
endmodule
module top ();
  sub #(.W((3+1))) u();
endmodule

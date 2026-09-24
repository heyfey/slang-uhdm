// § paramFoldParenSpan131
module sub #(parameter W = 8, parameter D = (W > 4 ? 1 : 0)) ();
endmodule
module top ();
  sub #(.W(2)) u();
endmodule

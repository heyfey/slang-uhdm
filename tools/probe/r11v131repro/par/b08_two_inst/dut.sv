// § paramFoldParenSpan131
module sub #(parameter W = (2 + 2), parameter V = (W * 3)) ();
endmodule
module top ();
  sub u1();
  sub #(.W(7)) u2();
endmodule

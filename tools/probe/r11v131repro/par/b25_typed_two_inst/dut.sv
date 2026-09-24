// § paramFoldParenSpan131
module sub #(parameter int W = (2 + 2), parameter int V = (W * 3)) ();
endmodule
module top ();
  sub u1();
  sub #(.W(7)) u2();
endmodule

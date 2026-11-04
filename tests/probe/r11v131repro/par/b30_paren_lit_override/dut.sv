// § paramFoldParenSpan131
module sub #(parameter int W = (8)) ();
endmodule
module top ();
  sub u1();
  sub #(.W(3)) u2();
endmodule

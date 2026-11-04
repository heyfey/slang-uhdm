// § paramFoldParenSpan131
module sub #(parameter S = ("ab"), parameter int K = (4)) ();
endmodule
module top ();
  sub #(.K(5)) u();
endmodule

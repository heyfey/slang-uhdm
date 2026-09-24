// § paramFoldParenSpan131
`define SUM(a, b) ((a) + (b))
module sub #(parameter int W = `SUM(2, 3)) ();
endmodule
module top ();
  sub u();
endmodule

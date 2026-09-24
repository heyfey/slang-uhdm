// § paramFoldParenSpan131
module sub #(parameter max_val_p = 7, parameter lg_p = ($clog2(max_val_p+1)), parameter r = 0) ();
endmodule
module top ();
  sub #(.lg_p(10), .r(0)) u();
endmodule

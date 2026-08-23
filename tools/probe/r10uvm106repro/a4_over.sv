// a4: overrides (named, positional, defparam) plus 1..3 instances
module a4_child #(parameter O_P = 'hf000000, parameter O_Q = 'b101) ();
  initial $display(O_P, O_Q);
endmodule
module a4_dp;
  parameter O_D = 'h5;
  initial $display(O_D);
endmodule
module a4_top;
  a4_child           k0 ();
  a4_child #(.O_P('hF)) k1 ();
  a4_child #('hAB, 'b11) k2 ();
  a4_child           k3 ();
  a4_dp d1();
  defparam d1.O_D = 'hE;
endmodule

// b04: overrides -- named / positional / defparam / hierarchical defparam,
// 1..3 instances, override VALUE also an unsized literal and also sized/plain.
module b04_child #(parameter P = 'hf000000, parameter Q = 'b101, parameter R = 'd7) ();
  localparam L = 'h1a;
  initial $display(P, Q, R, L);
endmodule
module b04_mid #(parameter MP = 'h5) ();
  b04_child #(.P(MP)) g0 ();
  b04_child           g1 ();
endmodule
module b04_dp;
  parameter DP = 'h5;
  localparam DL = 'h6;
  initial $display(DP, DL);
endmodule
module b04_top;
  b04_child                          k0 ();
  b04_child #(.P('hFF))              k1 ();
  b04_child #('hAB, 'b11, 'd3)       k2 ();
  b04_child #(.P(32'hFF))            k3 ();
  b04_child #(.P(15))                k4 ();
  b04_child #(.Q('b0))               k5 ();
  b04_mid                            m0 ();
  b04_mid #(.MP('hCC))               m1 ();
  b04_dp d0();
  b04_dp d1();
  defparam d0.DP = 'hE;
  defparam d1.DP = 20;
endmodule

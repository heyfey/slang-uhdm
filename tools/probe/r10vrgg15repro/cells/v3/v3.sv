// v3 — NON-fill override actuals into a 6-bit formal (must not move).
module h6 #(parameter bit [5:0] P = '0) (); endmodule
module h6s #(parameter logic signed [5:0] P = '0) (); endmodule
module h8 #(parameter bit [7:0] P = 1'b0) (); endmodule
module v3;
  h6 #('b0)  a_b0  ();
  h6 #('h0)  a_h0  ();
  h6 #('d0)  a_d0  ();
  h6 #(1'b0) a_1b0 ();
  h6 #(6'd0) a_6d0 ();
  h6 #(8'd0) a_8d0 ();
  h6 #(0)    a_0   ();
  h6 #(3)    a_3   ();
  h6s #(-1)  s_m1  ();
  h6s #(-3)  s_m3  ();
  h6s #('sb1) s_sb1 ();
  h8 d_h8 ();
  h8 #('0) o_h8 ();
endmodule

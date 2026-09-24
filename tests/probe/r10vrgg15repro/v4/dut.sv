// v4 — NO-DEFAULT vs WITH-DEFAULT formals, all four fills as override actuals.
module n0 #(parameter bit [5:0] Q)             (); endmodule
module n1 #(parameter bit [5:0] Q = '0)        (); endmodule
module n2 #(parameter bit [5:0] Q = 6'h0)      (); endmodule
module n3 #(parameter bit [5:0] Q = 6'h3 + 1)  (); endmodule
module n4 #(parameter bit [5:0] Q = '1)        (); endmodule
module v4;
  n0 #('0) a0 ();  n0 #('1) a1 ();  n0 #('x) ax ();  n0 #('z) az ();
  n1 #('0) b0 ();  n1 #('1) b1 ();  n1 #('x) bx ();  n1 #('z) bz ();
  n2 #('0) c0 ();  n2 #('1) c1 ();  n2 #('x) cx ();  n2 #('z) cz ();
  n3 #('0) d0 ();  n3 #('1) d1 ();
  n4 #('0) e0 ();  n4 #('1) e1 ();
  n1 f1 (); n2 f2 (); n3 f3 (); n4 f4 ();
endmodule

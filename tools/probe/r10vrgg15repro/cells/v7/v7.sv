// v7 — HARD SHAPES: ranged-untyped formals, type-parameter formals, unions,
// hierarchy pass-down, defparam, real/time, unpacked arrays.
module r8   #(parameter [7:0] P = '0)                      (); endmodule
module r1   #(parameter [0:0] P = '0)                      (); endmodule
module rsg  #(parameter signed [7:0] P = '0)               (); endmodule
module tp   #(parameter type T = bit [5:0], parameter T P = '0) (); endmodule
typedef union packed { bit [5:0] a; bit [5:0] b; } un6;
module un   #(parameter un6 P = '0)                        (); endmodule
module rl   #(parameter real R = 0.0)                      (); endmodule
module tm   #(parameter time TT = 0)                       (); endmodule
module child #(parameter bit [9:0] CP = '0)                (); endmodule
module mid   #(parameter bit [9:0] MP = '0) ();
  child #(MP)  c_pass ();
  child #('0)  c_own  ();
endmodule
module dp #(parameter bit [5:0] DP = '0) (); endmodule
module v7;
  r8   #('0) a8   ();
  r1   #('0) a1   ();
  rsg  #('0) asg  ();
  tp   #(.T(bit [12:0]), .P('0)) t13 ();
  tp   #(.P('0))                 t6d ();
  tp   #(.T(int), .P('0))        tint ();
  un   #('0) aun  ();
  tm   #('0) atm  ();
  mid  #('0) m0   ();
  mid  #(10'h3ff) m1 ();
  dp   d0 ();
  defparam d0.DP = '0;
endmodule

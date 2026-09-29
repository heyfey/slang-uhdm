// § importVarElemOwnName214 — a package two-dimensional fixed array of an enum and an associative array of a class keyed by int, inherited by classes of two importing packages
package p;
  typedef enum logic [1:0] {S0, S1, S2} s_e;
  class obj_c; int k; endclass
  s_e grid2 [2][3];
  obj_c objs [int];
endpackage
package q1;
  import p::*;
  class c1; int a; endclass
endpackage
package q2;
  import p::*;
  class c2; int b; endclass
endpackage
module top;
endmodule

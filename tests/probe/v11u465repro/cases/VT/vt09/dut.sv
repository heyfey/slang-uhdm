// § pkgTransImpAggTd465
// C holds a packed union and a vector typedef (the law's kinds absent: control)
package C;
  typedef union packed { logic [3:0] a; bit [3:0] b; } u_t;
  typedef logic [5:0] v_t;
endpackage
package B;
  import C::*;
  u_t bv;
endpackage
package A;
  import B::*;
  int av;
endpackage
module top;
  import A::*;
endmodule

// § pkgTransImpAggTd465
// B declares a vector typedef e_t and wildcard-imports C whose enum is also e_t; A imports B
package C;
  typedef enum {C0, C1} e_t;
endpackage
package B;
  import C::*;
  typedef logic [3:0] e_t;
  e_t bv;
endpackage
package A;
  import B::*;
  int av;
endpackage
module top;
  import A::*;
endmodule

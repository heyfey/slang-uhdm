// § pkgTransImpAggTd465
// A imports one item of B explicitly; B wildcard-imports C (no wildcard at A: control)
package C;
  typedef enum {C0, C1} e_t;
endpackage
package B;
  import C::*;
  int bx;
endpackage
package A;
  import B::bx;
  int av;
endpackage
module top;
  import A::*;
endmodule

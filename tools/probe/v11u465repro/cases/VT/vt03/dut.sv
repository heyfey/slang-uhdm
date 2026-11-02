// § pkgTransImpAggTd465
// B wildcard-imports C and D, both declaring an enum e_t (never referenced in B); A imports B
package C;
  typedef enum {C0, C1} e_t;
endpackage
package D;
  typedef enum {D0, D1, D2} e_t;
endpackage
package B;
  import C::*;
  import D::*;
  int bv;
endpackage
package A;
  import B::*;
  int av;
endpackage
module top;
  import A::*;
endmodule

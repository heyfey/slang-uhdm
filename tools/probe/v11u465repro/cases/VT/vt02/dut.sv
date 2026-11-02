// § pkgTransImpAggTd465
// A declares its own enum e_t and wildcard-imports B, which wildcard-imports C with an enum e_t
package C;
  typedef enum {C0, C1} e_t;
endpackage
package B;
  import C::*;
  e_t bv;
endpackage
package A;
  import B::*;
  typedef enum {A0, A1, A2} e_t;
  e_t av;
endpackage
module top;
  import A::*;
endmodule

// § pkgTransImpAggTd465
// B declares its own enum e_t and also wildcard-imports C, which has an enum e_t; A imports B
package C;
  typedef enum {C0, C1} e_t;
  typedef struct packed { logic [1:0] f; } s_t;
endpackage
package B;
  import C::*;
  typedef enum {B0, B1, B2} e_t;
  e_t bv;
endpackage
package A;
  import B::*;
  e_t av;
endpackage
module top;
  import A::*;
endmodule

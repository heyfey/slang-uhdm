// § pkgTransImpAggTd465
// A imports B then C directly; B imports C (struct over enum)
package C;
  typedef enum logic [1:0] {C0, C1} e_t;
  typedef struct packed { e_t a; logic [2:0] b; } s_t;
endpackage
package B;
  import C::*;
  s_t bv;
endpackage
package A;
  import B::*;
  import C::*;
  e_t av;
endpackage
module top;
  import A::*;
endmodule

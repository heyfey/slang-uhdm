// § pkgTransImpAggTd465
// C holds an enum, an enum alias of it and a struct with the enum member; A -> B -> C
package C;
  typedef enum {C0, C1} e_t;
  typedef e_t e2_t;
  typedef struct packed { e2_t m; logic n; } s_t;
endpackage
package B;
  import C::*;
  s_t bv;
endpackage
package A;
  import B::*;
  int av;
endpackage
module top;
  import A::*;
endmodule

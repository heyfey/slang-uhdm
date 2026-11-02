// § pkgTransImpAggTd465
// diamond: A imports B and D, both wildcard-import C (enum and struct)
package C;
  typedef enum {C0, C1} e_t;
  typedef struct packed { e_t e; logic [2:0] g; } s_t;
endpackage
package B;
  import C::*;
  s_t bv;
endpackage
package D;
  import C::*;
  e_t dv;
endpackage
package A;
  import B::*;
  import D::*;
  int av;
endpackage
module top;
  import A::*;
endmodule

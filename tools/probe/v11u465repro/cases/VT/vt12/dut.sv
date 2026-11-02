// § pkgTransImpAggTd465
// B imports C explicitly for one enum and wildcard for D; A imports B
package C;
  typedef enum {C0, C1} e_t;
  typedef enum {K0, K1} k_t;
endpackage
package D;
  typedef struct packed { logic [1:0] a; } s_t;
endpackage
package B;
  import C::e_t;
  import D::*;
  e_t bv;
endpackage
package A;
  import B::*;
  int av;
endpackage
module top;
  import A::*;
endmodule

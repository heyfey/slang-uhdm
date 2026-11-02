// § pkgTransImpAggTd465
// two outer packages A1 and A2 both import B (B imports C): last-writer stamp, then a module imports A1
package C;
  typedef enum {C0, C1} e_t;
  typedef struct { int x; } u_t;
endpackage
package B;
  import C::*;
  e_t bv;
endpackage
package A1;
  import B::*;
  int a1;
endpackage
package A2;
  import B::*;
  int a2;
endpackage
module top;
  import A1::*;
endmodule

// § pkgTransImpEarlierOnly465v
// C is declared after B, which wildcard-imports it; A imports B (declaration order reversed)
package B;
  import C::*;
  int bv;
endpackage
package C;
  typedef enum {C0, C1} e_t;
  typedef struct packed { logic [1:0] a; } s_t;
endpackage
package A;
  import B::*;
  int av;
endpackage
module top;
  import A::*;
endmodule

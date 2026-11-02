// § pkgTransImpAggTd465
// B wildcard-imports C; A imports B and declares a struct over C::e_t (scoped)
package C;
  typedef enum logic [1:0] {C0, C1, C2} e_t;
endpackage
package B;
  import C::*;
  function automatic e_t g(); return C2; endfunction
endpackage
package A;
  import B::*;
  typedef struct packed { C::e_t a; logic b; } as_t;
  as_t av;
endpackage
module top;
  import A::*;
  as_t m;
endmodule

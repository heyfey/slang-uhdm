// § pkgTransImpAggTd465
// B imports and re-exports C (export C::*); A imports B
package C;
  typedef enum {C0, C1} e_t;
  typedef struct packed { logic [3:0] a; } s_t;
endpackage
package B;
  import C::*;
  export C::*;
  e_t bv;
  s_t bs;
endpackage
package A;
  import B::*;
  s_t av;
endpackage
module top;
  import A::*;
endmodule

// § pkgTransImpAggTd465
// A declares its own struct s_t; B imports C whose struct is also s_t; A imports B
package C;
  typedef struct packed { logic [3:0] c; } s_t;
endpackage
package B;
  import C::*;
  s_t bv;
endpackage
package A;
  import B::*;
  typedef struct packed { logic [1:0] a; } s_t;
  s_t av;
endpackage
module top;
  import A::*;
endmodule

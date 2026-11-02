// § pkgTransImpAggTd465
// C holds a struct of a struct; A -> B -> C
package C;
  typedef struct packed { logic [1:0] p; } in_t;
  typedef struct packed { in_t i; logic q; } out_t;
endpackage
package B;
  import C::*;
  out_t bv;
endpackage
package A;
  import B::*;
  int av;
endpackage
module top;
  import A::*;
endmodule

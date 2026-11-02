// § pkgTransImpAggTd465
// four hops: A -> B -> C -> D, D holds an enum and an unpacked struct
package D;
  typedef enum logic [2:0] {D0=1, D1=3} e_t;
  typedef struct { int x; e_t y; } u_t;
endpackage
package C;
  import D::*;
  e_t cv;
endpackage
package B;
  import C::*;
  int bv;
endpackage
package A;
  import B::*;
  int av;
endpackage
module top;
  import A::*;
endmodule

// § pkgTransImpAggTd465
// A -> B -> C -> D, and B also imports D directly
package D;
  typedef enum {D0, D1} d_e;
  typedef struct packed { logic [1:0] x; } d_s;
endpackage
package C;
  import D::*;
  d_e cv;
endpackage
package B;
  import C::*;
  import D::*;
  d_s bv;
endpackage
package A;
  import B::*;
  int av;
endpackage
module top;
  import A::*;
endmodule

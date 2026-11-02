// § pkgTransImpEarlierOnly465v
// A imports B declared after it; B imports C; an earlier D also imports C so C's clones exist when A is emitted
package C;
  typedef enum {C0, C1} e_t;
  typedef struct packed { logic [1:0] a; } s_t;
endpackage
package D;
  import C::*;
  e_t dv;
endpackage
package A;
  import B::*;
  int av;
endpackage
package B;
  import C::*;
  int bv;
endpackage
module top;
  import A::*;
endmodule

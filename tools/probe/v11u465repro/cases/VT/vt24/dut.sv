// § pkgTransImpEarlierOnly465v
// fully reversed declaration order: A (imports B), then B (imports C), then C
package A;
  import B::*;
  int av;
endpackage
package B;
  import C::*;
  int bv;
endpackage
package C;
  typedef enum {C0, C1} e_t;
  typedef struct packed { logic [1:0] a; } s_t;
endpackage
module top;
  import A::*;
endmodule

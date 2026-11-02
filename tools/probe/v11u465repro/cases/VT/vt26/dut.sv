// § pkgTransImpEarlierOnly465v
// B imports C declared after B, and an earlier D imports C; A (after all) imports B
package D0;
  int d0;
endpackage
package B;
  import C::*;
  int bv;
endpackage
package C;
  typedef enum {C0, C1} e_t;
endpackage
package D;
  import C::*;
  e_t dv;
endpackage
package A;
  import B::*;
  int av;
endpackage
module top;
  import A::*;
endmodule

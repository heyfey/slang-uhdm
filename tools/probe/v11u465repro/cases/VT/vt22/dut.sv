// § pkgTransImpAggTd465
// the outer package is imported inside a class-free module that never uses it, plus a second module importing B
package C;
  typedef enum logic {C0, C1} e_t;
endpackage
package B;
  import C::*;
  e_t bv;
endpackage
package A;
  import B::*;
  int av;
endpackage
module m2;
  import B::*;
endmodule
module top;
  import A::*;
  m2 u();
endmodule

// § pkgTransImpAggTd465
// B aliases C's enum (typedef e_t be_t); A imports B
package C;
  typedef enum {C0, C1, C2} e_t;
endpackage
package B;
  import C::*;
  typedef e_t be_t;
  be_t bv;
endpackage
package A;
  import B::*;
  be_t av;
endpackage
module top;
  import A::*;
endmodule

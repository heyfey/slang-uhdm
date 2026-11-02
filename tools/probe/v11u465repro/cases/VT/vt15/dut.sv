// § pkgTransImpAggTd465
// C's enum used by a class in B; A imports B
package C;
  typedef enum {RD, WR} op_e;
endpackage
package B;
  import C::*;
  class T;
    op_e op;
    function op_e get(); return op; endfunction
  endclass
endpackage
package A;
  import B::*;
  class E;
    T t;
  endclass
endpackage
module top;
  import A::*;
endmodule

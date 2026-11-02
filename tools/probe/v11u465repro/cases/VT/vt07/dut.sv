// § pkgTransImpAggTd465
// B imports C only inside a function body (not a package item); A imports B
package C;
  typedef enum {C0, C1} e_t;
endpackage
package B;
  function automatic int f();
    import C::*;
    e_t x = C1;
    return int'(x);
  endfunction
endpackage
package A;
  import B::*;
  int av;
endpackage
module top;
  import A::*;
endmodule

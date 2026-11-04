// § cloneLvSharesHomeUnitTs465
// an associative class property indexed by an enum
package h;
  typedef enum {E0, E1} e_t;
  class C;
    int m[e_t];
    extern function int f();
  endclass
  function int C::f();
    int s;
    foreach (m[k]) s += m[k];
    return s;
  endfunction
endpackage
package a;
  import h::*;
endpackage
import a::*;
module top;
endmodule

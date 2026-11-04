// § cloneLvSharesHomeUnitTs465
// an associative class property indexed by byte
package h;
  class C;
    int m[byte];
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

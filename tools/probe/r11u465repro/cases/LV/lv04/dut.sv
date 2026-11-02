// § cloneLvSharesHomeUnitTs465
// an associative class property indexed by int (pack_object_with_meta's shape)
package h;
  class C;
    int m[int];
    extern function int f();
  endclass
  function int C::f();
    int s;
    foreach (m[i]) s += m[i];
    return s;
  endfunction
endpackage
package a;
  import h::*;
endpackage
import a::*;
module top;
endmodule

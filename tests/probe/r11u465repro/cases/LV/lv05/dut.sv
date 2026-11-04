// § cloneLvSharesHomeUnitTs465
// an associative class property indexed by a class (uvm_phase::add's shape)
package h;
  class C;
    bit m[C];
    extern function int f();
  endclass
  function int C::f();
    int s;
    foreach (m[p]) s++;
    return s;
  endfunction
endpackage
package a;
  import h::*;
endpackage
import a::*;
module top;
endmodule

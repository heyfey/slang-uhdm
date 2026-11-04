// § cloneLvSharesHomeUnitTs465
// the $unit import written after the module
package h;
  class C;
    int q[$];
    extern function void f();
  endclass
  function void C::f();
    foreach (q[i]) q[i] = 0;
  endfunction
endpackage
package a;
  import h::*;
endpackage
module top;
endmodule
import a::*;

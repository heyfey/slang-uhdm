// § cloneLvSharesHomeUnitTs465
// the same with a direct $unit import of the home package
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
import h::*;
module top;
endmodule

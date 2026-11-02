// § cloneLvSharesHomeUnitTs465
// a class-property queue in an out-of-body method; $unit import of a, which imports h
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
import a::*;
module top;
endmodule

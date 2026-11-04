// § cloneLvSharesHomeUnitTs465
// a derived class reading a base-class queue property in an out-of-body method
package h;
  class B;
    int q[$];
  endclass
  class D extends B;
    extern function void f();
  endclass
  function void D::f();
    foreach (q[i]) q[i] = 0;
  endfunction
endpackage
package a;
  import h::*;
endpackage
import a::*;
module top;
endmodule

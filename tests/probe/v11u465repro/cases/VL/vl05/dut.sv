// § cloneLvSharesHomeUnitTs465
// a class property typed by a package queue typedef
package h;
  typedef int iq_t[$];
  class C;
    iq_t q;
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

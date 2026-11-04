// § cloneLvSharesHomeUnitTs465
// two out-of-body methods, each with a foreach whose loop variable is i
package h;
  class C;
    int q[$];
    byte d[];
    extern function void f();
    extern function void g();
  endclass
  function void C::f();
    foreach (q[i]) q[i] = 1;
  endfunction
  function void C::g();
    foreach (d[i]) d[i] = 2;
  endfunction
endpackage
package a;
  import h::*;
endpackage
import a::*;
module top;
endmodule

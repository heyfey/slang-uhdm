// § cloneLvSharesHomeUnitTs465
// nested foreach over two class properties
package h;
  class C;
    int q[$];
    byte d[];
    extern function void f();
  endclass
  function void C::f();
    foreach (q[i]) foreach (d[j]) d[j] = q[i];
  endfunction
endpackage
package a;
  import h::*;
endpackage
import a::*;
module top;
endmodule

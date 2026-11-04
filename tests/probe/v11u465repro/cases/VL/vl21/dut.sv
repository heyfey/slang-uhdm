// § cloneLvSharesHomeUnitTs465
// a class property dynamic array of class handles
package h;
  class W;
    int v;
  endclass
  class C;
    W ws[];
    extern function void f();
  endclass
  function void C::f();
    foreach (ws[k]) ws[k].v = k;
  endfunction
endpackage
package a;
  import h::*;
endpackage
import a::*;
module top;
endmodule

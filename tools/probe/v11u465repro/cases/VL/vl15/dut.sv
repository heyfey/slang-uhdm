// § cloneLvSharesHomeUnitTs465
// an associative class property with a packed element, indexed by string, out-of-body
package h;
  class C;
    bit [7:0] m[string];
    extern function void f();
  endclass
  function void C::f();
    foreach (m[s]) m[s] = 8'h1;
  endfunction
endpackage
package a;
  import h::*;
endpackage
import a::*;
module top;
endmodule

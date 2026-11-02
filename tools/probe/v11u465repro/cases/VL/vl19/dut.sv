// § cloneLvSharesHomeUnitTs465
// a static class queue property
package h;
  class C;
    static int sq[$];
    extern static function void f();
  endclass
  function void C::f();
    foreach (sq[i]) sq[i] = 0;
  endfunction
endpackage
package a;
  import h::*;
endpackage
import a::*;
module top;
endmodule

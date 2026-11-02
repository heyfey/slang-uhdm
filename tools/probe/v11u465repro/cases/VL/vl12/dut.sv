// § cloneLvSharesHomeUnitTs465
// a module-local class (not in a package) with a queue foreach; $unit imports a which imports h (h has no loop)
package h;
  int x;
endpackage
package a;
  import h::*;
endpackage
import a::*;
module top;
  class C;
    int q[$];
    function void f(); foreach (q[i]) q[i] = 0; endfunction
  endclass
endmodule

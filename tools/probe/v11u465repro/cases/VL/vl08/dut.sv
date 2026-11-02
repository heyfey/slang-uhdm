// § cloneLvSharesHomeUnitTs465
// an in-body method (not extern) over a class queue property
package h;
  class C;
    int q[$];
    function void f();
      foreach (q[i]) q[i] = 0;
    endfunction
  endclass
endpackage
package a;
  import h::*;
endpackage
import a::*;
module top;
endmodule

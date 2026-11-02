// § cloneLvSharesHomeUnitTs465
// control: no $unit import, the law must not fire
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
module top;
  import a::*;
endmodule

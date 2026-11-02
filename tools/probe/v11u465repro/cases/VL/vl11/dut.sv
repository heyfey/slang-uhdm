// § cloneLvSharesHomeUnitTs465
// the loop variable read in a call argument inside a class queue foreach; module also imports h
package h;
  class C;
    int q[$];
    extern function void f();
    function void p(int x); endfunction
  endclass
  function void C::f();
    foreach (q[i]) p(i);
  endfunction
endpackage
package a;
  import h::*;
endpackage
import a::*;
module top;
  import h::*;
  C c;
endmodule

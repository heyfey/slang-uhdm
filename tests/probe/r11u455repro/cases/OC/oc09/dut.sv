// § oobInheritedCallBindsOwnPkgClone455
package p;
  function int f(int a); $display(a); return a; endfunction
  class B;
    function int f(int a); return a + 1; endfunction
  endclass
endpackage
package q;
  import p::*;
  class C extends B;
    int v;
    extern function int g();
    extern function int m(int a);
  endclass
  function int C::g(); if (f(v) > 1) return m(f(v)); return 0; endfunction
  function int C::m(int a); return a; endfunction
endpackage
module top;
  import q::*;
  C c;
  initial begin c = new; $display(c.g()); end
endmodule

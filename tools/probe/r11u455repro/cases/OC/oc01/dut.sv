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
    function int h(); return f(v); endfunction
  endclass
  function int C::g(); return f(v); endfunction
endpackage
module top;
  import q::*;
  C c;
  initial begin c = new; $display(c.g(), c.h()); end
endmodule

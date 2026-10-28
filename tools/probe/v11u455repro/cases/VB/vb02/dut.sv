// § oobInheritedCallBindsOwnPkgClone455
// control: inherited method with no free twin (no fallback expected)
package r;
  class B;
    function int f(int a); return a + 1; endfunction
  endclass
endpackage
package p;
  function int k(int a); return a; endfunction
endpackage
package q;
  import p::*;
  import r::*;
  class C extends B;
    int v;
    extern function int g();
  endclass
  function int C::g(); return f(v) + k(v); endfunction
endpackage
module top;
  import q::*;
  C c;
  initial begin c = new; $display(c.g()); end
endmodule

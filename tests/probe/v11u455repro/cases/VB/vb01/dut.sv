// § oobInheritedCallBindsOwnPkgClone455
// base class in a third package r; free f in p; q imports p and r
package p;
  function int f(int a); $display(a); return a; endfunction
endpackage
package r;
  class B;
    function int f(int a); return a + 1; endfunction
  endclass
endpackage
package q;
  import p::*;
  import r::*;
  class C extends B;
    int v;
    extern function int g();
  endclass
  function int C::g(); return f(v); endfunction
endpackage
module top;
  import q::*;
  C c;
  initial begin c = new; $display(c.g()); end
endmodule

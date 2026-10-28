// § oobInheritedCallBindsOwnPkgClone455
package p;
  function int f(int a); $display(a); return a; endfunction
endpackage
package q;
  import p::*;
  class C;
    int v;
    extern function int g();
    function int f(int a); return a + 1; endfunction
  endclass
  function int C::g(); return f(v); endfunction
endpackage
module top;
  import q::*;
  C c;
  initial begin c = new; $display(c.g()); end
endmodule

// § oobInheritedCallBindsOwnPkgClone455
// explicit import p::f (not wildcard) in q; OOB call f(v)
package p;
  function int f(int a); $display(a); return a; endfunction
endpackage
package q;
  import p::f;
  class C;
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

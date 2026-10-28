// § oobInheritedCallBindsOwnPkgClone455
// both explicit and wildcard import of p in q
package p;
  function int f(int a); $display(a); return a; endfunction
  function int k(int a); return a * 2; endfunction
endpackage
package q;
  import p::*;
  import p::k;
  class C;
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

// § oobInheritedCallBindsOwnPkgClone455
// s imports p and q (both): s's copy of q's out-of-body method
package p;
  function int f(int a); $display(a); return a; endfunction
endpackage
package q;
  import p::*;
  class C;
    int v;
    extern function int g();
  endclass
  function int C::g(); return f(v); endfunction
endpackage
package s;
  import p::*;
  import q::*;
  function int h(); C c = new; return c.g() + f(1); endfunction
endpackage
module top;
  import s::*;
  initial $display(h());
endmodule

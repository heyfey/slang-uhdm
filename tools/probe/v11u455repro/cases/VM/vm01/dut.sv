// § oobInheritedCallBindsOwnPkgClone455
// two classes in q, two OOB methods, both call f; plus a package function in q calling f
package p;
  function int f(int a); $display(a); return a; endfunction
endpackage
package q;
  import p::*;
  class C;
    int v;
    extern function int g();
  endclass
  class D;
    int w;
    extern function int h();
  endclass
  function int C::g(); return f(v); endfunction
  function int D::h(); return f(w) + f(1); endfunction
  function int pf(); return f(9); endfunction
endpackage
module top;
  import q::*;
  C c; D d;
  initial begin c = new; d = new; $display(c.g(), d.h(), pf()); end
endmodule

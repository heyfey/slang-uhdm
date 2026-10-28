// § oobInheritedCallBindsOwnPkgClone455
// two modules import q; module-level class use in both
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
module sub;
  import q::*;
  C c;
  initial begin c = new; $display(c.g()); end
endmodule
module top;
  import q::*;
  C c;
  sub u1();
  initial begin c = new; $display(c.g()); end
endmodule

// § oobInheritedCallBindsOwnPkgClone455
// imported function call in an OOB virtual method overriding a base method
package p;
  function int f(int a); $display(a); return a; endfunction
endpackage
package q;
  import p::*;
  virtual class B;
    pure virtual function int g();
  endclass
  class C extends B;
    int v;
    extern virtual function int g();
  endclass
  function int C::g(); if (f(v) > 0) return f(1); else return f(2); endfunction
endpackage
module top;
  import q::*;
  C c;
  initial begin c = new; $display(c.g()); end
endmodule

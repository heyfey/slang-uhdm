// § oobInheritedCallBindsOwnPkgClone455
// outer class with a nested class; outer OOB method calls f, nested in-class method calls f
package p;
  function int f(int a); $display(a); return a; endfunction
endpackage
package q;
  import p::*;
  class O;
    class I;
      int v;
      function int h(); return f(v); endfunction
    endclass
    int w;
    extern function int g();
  endclass
  function int O::g(); I i = new; return f(w) + i.h(); endfunction
endpackage
module top;
  import q::*;
  O c;
  initial begin c = new; $display(c.g()); end
endmodule

// § oobCloneViewKeepsPristine455v
// importer s imports only q (not p): s's copy of q's out-of-body method
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
  import q::*;
  class D;
    C c;
    function int h(); c = new; return c.g(); endfunction
  endclass
endpackage
module top;
  import s::*;
  D d;
  initial begin d = new; $display(d.h()); end
endmodule

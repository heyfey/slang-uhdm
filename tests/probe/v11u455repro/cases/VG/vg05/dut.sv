// § oobCloneViewKeepsPristine455v
// two-level importer chain: s imports q, u imports s; q's OOB calls p::f
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
  function int h(); C c = new; return c.g(); endfunction
endpackage
package u;
  import s::*;
  function int k(); return h(); endfunction
endpackage
module top;
  import u::*;
  initial $display(k());
endmodule

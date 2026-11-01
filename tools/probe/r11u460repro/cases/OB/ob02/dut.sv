// § oobCopyCallBindsBodyHomeClone460
package p;
  function int f(int a); int cs; cs = a; return cs; endfunction
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
  class D extends C;
    function int h(); return g(); endfunction
  endclass
endpackage
module top;
  import s::*;
  D d;
  initial begin d = new; $display(d.h()); end
endmodule

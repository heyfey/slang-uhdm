// § oobCopyCallBindsBodyHomeClone460 (class-extends shape, the inherited method shadows the free function)
package p;
  function int f(int a); $display(a); return a; endfunction
  class B;
    function int f(int a); return a + 1; endfunction
  endclass
endpackage
package q;
  import p::*;
  class C extends B;
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

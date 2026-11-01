// § oobCopyCallBindsBodyHomeClone460 (q declares its own f: control)
package p;
  function int f(int a); int cs; cs = a; return cs; endfunction
  task t(output int o); int cs; cs = 3; o = cs; endtask
endpackage
package q;
  import p::*;
  function int f(int a); return a + 7; endfunction
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

// § oobCopyCallBindsBodyHomeClone460 (in-body method beside the out-of-body one)
package p;
  function int f(int a); int cs; cs = a; return cs; endfunction
  task t(output int o); int cs; cs = 3; o = cs; endtask
endpackage
package q;
  import p::*;
  class C;
    int v;
    function int inb(); return f(v); endfunction
    extern function int g();
  endclass
  function int C::g(); return f(v) + inb(); endfunction
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

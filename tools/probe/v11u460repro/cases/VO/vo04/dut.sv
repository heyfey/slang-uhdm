// § oobCopyCallBindsBodyHomeClone460 (three levels: r imports q, s imports r and p)
package p;
  function int f(int a); int cs; cs = a; return cs; endfunction
  task t(output int o); int cs; cs = 3; o = cs; endtask
endpackage
package q;
  import p::*;
  class C;
    int v;
    extern function int g();
  endclass
  function int C::g(); return f(v); endfunction
endpackage
package r;
  import p::*;
  import q::*;
  class E extends C; endclass
endpackage
package s;
  import p::*;
  import r::*;
  import q::*;
  class D extends E;
    function int h(); return g(); endfunction
  endclass
endpackage
module top;
  import s::*;
  D d;
  initial begin d = new; $display(d.h()); end
endmodule

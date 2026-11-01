// § oobCopyCallBindsBodyHomeClone460 (task shape, two calls and a function in one body)
package p;
  task t(output int o); int cs; cs = 3; o = cs; endtask
  function int f(int a); int cs; cs = a; return cs; endfunction
endpackage
package q;
  import p::*;
  class C;
    int v;
    extern task g();
  endclass
  task C::g(); t(v); v = f(v); t(v); endtask
endpackage
package s;
  import p::*;
  import q::*;
  class D extends C;
    task h(); g(); endtask
  endclass
endpackage
module top;
  import s::*;
  D d;
  initial begin d = new; d.h(); end
endmodule

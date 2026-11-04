// § oobCopyCallBindsBodyHomeClone460 (task shape, explicit import p::t in q)
package p;
  task t(output int o); int cs; cs = 3; o = cs; endtask
endpackage
package q;
  import p::t;
  class C;
    int v;
    extern task g();
  endclass
  task C::g(); t(v); endtask
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

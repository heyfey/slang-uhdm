// § oobCopyCallBindsBodyHomeClone460 (task shape, q declares its own task t: control)
package p;
  task t(output int o); int cs; cs = 3; o = cs; endtask
endpackage
package q;
  import p::*;
  task t(output int o); o = 9; endtask
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

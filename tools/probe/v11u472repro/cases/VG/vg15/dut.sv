// § grpOwnOobGenericCls472
package p;
  function void pf(); endfunction
endpackage
package q;
  import p::*;
  class D #(int W = 1);
    extern task run();
  endclass
  task D::run(); endtask
endpackage
package r;
  import q::*;
  class E #(int W = 1);
    extern task go();
  endclass
  task E::go(); endtask
endpackage
package t;
  import r::*;
  class S;
    int k;
  endclass
endpackage
module top;
  import t::*;
endmodule

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
  class D2 #(int W = 1);
    extern task run();
  endclass
  task D2::run(); endtask
endpackage
package r;
  import q::*;
  class S;
    D #(1) a;
    D2 #(7) b;
  endclass
endpackage
module top;
  import r::*;
endmodule

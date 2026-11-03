// § grpOwnOobGenericCls472
package p;
  function void pf(); endfunction
endpackage
package q;
  import p::*;
  class D;
    extern task run();
  endclass
  task D::run(); endtask
endpackage
package r;
  import q::*;
  class S;
    int k;
  endclass
endpackage
module top;
  import r::*;
endmodule

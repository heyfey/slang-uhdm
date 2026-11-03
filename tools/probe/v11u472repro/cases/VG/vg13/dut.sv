// § grpOwnOobGenericCls472
package p;
  function void pf(); endfunction
endpackage
package q;
  import p::*;
  class D #(int W);
    extern task run();
  endclass
  task D::run(); endtask
endpackage
package r;
  import q::*;
  typedef D #(3) d3_t;
  class S;
    d3_t h;
  endclass
endpackage
module top;
  import r::*;
endmodule

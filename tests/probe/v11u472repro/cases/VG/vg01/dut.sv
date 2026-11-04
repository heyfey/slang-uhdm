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
  typedef D #(4) d4_t;
  typedef D #(8) d8_t;
endpackage
package r;
  import q::*;
  class S;
    d4_t a;
    d8_t b;
  endclass
endpackage
module top;
  import r::*;
endmodule

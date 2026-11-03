// § grpOwnOobGenericCls472
package p;
  function void pf(); endfunction
endpackage
package q;
  import p::*;
  class D #(int W = 1);
    extern task run();
    extern function void build();
  endclass
  task D::run(); endtask
  function void D::build(); endfunction
endpackage
package r;
  import q::*;
  typedef D #(4) d4_t;
endpackage
package s;
  import p::*;
  import q::*;
  import r::*;
  class E;
    int k;
  endclass
endpackage
module top;
  import s::*;
endmodule

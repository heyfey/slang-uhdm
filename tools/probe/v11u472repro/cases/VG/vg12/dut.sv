// § grpOwnOobGenericCls472
package p;
  function void pf(); endfunction
endpackage
package q;
  import p::*;
  class D #(int W = 1);
    extern task run();
    extern function void zz();
    extern function void aa();
  endclass
  function void D::zz(); endfunction
  task D::run(); endtask
  function void D::aa(); endfunction
endpackage
package r;
  import q::*;
  class S;
    int k;
  endclass
endpackage
package t;
  import q::*;
  import r::*;
  class U;
    int k;
  endclass
endpackage
module top;
  import t::*;
endmodule

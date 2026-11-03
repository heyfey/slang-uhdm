// § grpOwnOobGenericCls472
package p;
  function void pf(); endfunction
endpackage
package q;
  import p::*;
  class D #(type T = int);
    extern task run();
  endclass
  task D::run(); endtask
  class G #(int W = 1);
    extern function void g();
  endclass
  function void G::g(); endfunction
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

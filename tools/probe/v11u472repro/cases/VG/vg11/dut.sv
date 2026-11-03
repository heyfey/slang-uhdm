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
endpackage
interface ifc;
  import r::*;
  class S;
    int k;
  endclass
endinterface
module top;
  ifc i();
endmodule

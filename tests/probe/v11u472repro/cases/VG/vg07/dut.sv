// § grpOwnOobGenericCls472
package p;
  function void pf(); endfunction
endpackage
package q;
  import p::*;
  class B;
    extern virtual function void hook();
  endclass
  function void B::hook(); endfunction
  class D #(int W = 1) extends B;
    extern virtual function void hook();
  endclass
  function void D::hook(); endfunction
endpackage
package r;
  import q::*;
  class S extends D #(2);
    int k;
  endclass
endpackage
module top;
  import r::*;
endmodule

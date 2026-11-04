// § grpOwnOobGenericCls472
package p;
  function void pf(); endfunction
endpackage
package q;
  import p::*;
  virtual class D #(int W = 1);
    pure virtual function void pv();
    extern function void run();
  endclass
  function void D::run(); endfunction
  class E extends D #(5);
    virtual function void pv(); endfunction
  endclass
endpackage
package r;
  import q::*;
  class S;
    E e;
  endclass
endpackage
module top;
  import r::*;
endmodule

// § grpOwnOobGenericCls472
package p;
  function void pf(); endfunction
endpackage
package q;
  import p::*;
  class D #(int W = 1, type T = logic [W-1:0]);
    T d;
    extern function void put(T x);
  endclass
  function void D::put(T x); d = x; endfunction
endpackage
package r;
  import q::*;
  class S;
    D #(4) h;
  endclass
endpackage
module top;
  import r::*;
  initial begin
    S s = new;
  end
endmodule

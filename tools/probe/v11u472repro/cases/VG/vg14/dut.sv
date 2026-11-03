// § grpOwnOobGenericCls472
package p;
  function void pf(); endfunction
endpackage
package q;
  import p::*;
  class D #(type T = int);
    T v;
    extern function void put(T x);
  endclass
  function void D::put(T x); v = x; endfunction
endpackage
package r;
  import q::*;
  class S;
    D #(byte) a;
    D #(int) b;
    D #(logic [3:0]) c;
  endclass
endpackage
module top;
  import r::*;
endmodule

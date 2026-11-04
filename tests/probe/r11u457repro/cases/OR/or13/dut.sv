// § oobClsRetCallSharesCalleeRet457
package p;
  parameter int P = 4;
  function int rep(int v);
    return v + 1;
  endfunction
  class C;
    int w;
    extern function int f(int a);
  endclass
  function int C::f(int a);
    w = rep(a); return rep(a);
  endfunction
endpackage
module top;
  import p::*;
  C c;
endmodule

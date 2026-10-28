// § oobClsRetCallSharesCalleeRet457
package p;
  function int rep(int v); return v + 1; endfunction
  class C;
    extern function int f(int a);
  endclass
  function int C::f(int a);
    int t;
    t = a;
    return rep(t);
  endfunction
endpackage
module top;
  import p::*;
  C c;
endmodule

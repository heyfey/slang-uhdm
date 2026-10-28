// § oobClsRetCallSharesCalleeRet457
package p;
  function int rep(int v); return v + 1; endfunction
  class C;
    extern function int f(int a);
  endclass
  function int C::f(int a);
    if (a > 2) return rep(a);
    return 0;
  endfunction
endpackage
module top;
  import p::*;
  C c;
endmodule

// § oobClsRetCallSharesCalleeRet457
package p;
  class C;
    extern function int f(int a);
  endclass
  function int rep(int v);
    return v + 1;
  endfunction
  function int C::f(int a);
    return rep(a);
  endfunction
endpackage
module top;
  import p::*;
  C c;
endmodule

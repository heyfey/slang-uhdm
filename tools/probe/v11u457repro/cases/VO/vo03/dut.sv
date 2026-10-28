// § oobClsRetCallSharesCalleeRet457
package p;
  function int rep(int v); return v + 1; endfunction
  class C #(int N = 1);
    extern function int f(int a);
  endclass
  function int C::f(int a);
    return rep(a);
  endfunction
endpackage
module top;
  import p::*;
  C #(2) c;
endmodule

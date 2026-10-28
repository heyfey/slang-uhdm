// § oobClsRetCallSharesCalleeRet457
package p;
  parameter int K = 3;
  function int rep(int v); return v + K; endfunction
  function int rep2(int v); return v + 1; endfunction
  class C;
    extern function int f(int a);
  endclass
  function int C::f(int a);
    return rep2(K);
  endfunction
endpackage
module top;
  import p::*;
  C c;
endmodule

// § oobClsRetCallSharesCalleeRet457
package p;
  function int rep(int v);
    return v + 1;
  endfunction
  function int rep2(int v, int w);
    return v + w;
  endfunction
  class C;
    int w;
    function int m(int v); return v * 2; endfunction
    extern function int f(int a);
  endclass
  function int C::f(int a);
    if (rep(a) > 0) return 1; return 0;
  endfunction
endpackage
module top;
  import p::*;
  C c;
endmodule

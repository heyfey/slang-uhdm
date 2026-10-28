// § oobClsRetCallSharesCalleeRet457
package p;
  function int rep(int v);
    return v + 1;
  endfunction
  class C;
    extern function int f(int a);
    extern function int g(int a);
  endclass
  function int C::f(int a);
    int k;
    k = a;
    return rep(k);
  endfunction
  function int C::g(int a);
    return rep(a) == 0;
  endfunction
endpackage
module top;
  import p::*;
  C c;
endmodule

// § oobClsRetCallSharesCalleeRet457
package p;
  function int rep(int v); return v + 1; endfunction
  class B;
    function int g(int a); return a; endfunction
  endclass
  class C extends B;
    extern function int f(int a);
  endclass
  function int C::f(int a);
    return rep(a);
  endfunction
endpackage
module top;
  import p::*;
  C c;
endmodule

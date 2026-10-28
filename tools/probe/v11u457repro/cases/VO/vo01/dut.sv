// § oobClsRetCallSharesCalleeRet457
package r;
  function int rep(int v); return v + 1; endfunction
endpackage
package p;
  import r::*;
  class C;
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

// § oobClsRetCallSharesCalleeRet457
package p;
  function int rep(int v);
    return v + 1;
  endfunction
endpackage
package q;
  import p::*;
  class C;
    extern function int f(int a);
  endclass
  function int C::f(int a);
    return rep(a);
  endfunction
endpackage
module top;
  import q::*;
  C c;
endmodule

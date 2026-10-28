// § oobClsRetCallSharesCalleeRet457
package p;
  function int rep(int v); return v + 1; endfunction
  virtual class C;
    extern virtual function int f(int a);
  endclass
  function int C::f(int a);
    return rep(a);
  endfunction
  class D extends C;
  endclass
endpackage
module top;
  import p::*;
  D d;
endmodule

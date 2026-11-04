// § oobClsRetCallSharesCalleeRet457
package p;
  function int rep(int v); return v + 1; endfunction
  class C;
    extern function int f(int a);
    extern function int g(int a);
  endclass
  function int C::f(int a);
    return rep(a);
  endfunction
  function int C::g(int a);
    return rep(a);
  endfunction
endpackage
module top;
  import p::*;
  C c;
  initial begin c = new; $display(c.f(1)); end
endmodule

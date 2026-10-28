// § pkgRetCallSharesConstRet457
package p;
  function int rep(int v); return 3; endfunction
  class C;
    extern function int f(int a);
    extern function int g();
  endclass
  function int C::f(int a);
    return rep(a);
  endfunction
  function int C::g();
    return rep(4);
  endfunction
endpackage
module top;
  import p::*;
  C c;
endmodule

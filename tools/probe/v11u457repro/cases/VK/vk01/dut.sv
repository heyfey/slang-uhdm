// § pkgRetCallSharesConstRet457
package p;
  function integer rep(int v); return 3; endfunction
  function integer f(int a);
    return rep(a);
  endfunction
endpackage
module top;
  import p::*;
  integer x;
  initial x = f(2);
endmodule

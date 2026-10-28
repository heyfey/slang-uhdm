// § pkgRetCallSharesConstRet457
package p;
  function int unsigned rep(int v); return 9; endfunction
  function byte f(int a);
    return rep(a);
  endfunction
endpackage
module top;
  import p::*;
  int x;
  initial x = f(2);
endmodule

// § pkgRetCallSharesConstRet457
package p;
  function int rep(int v); return 3; endfunction
  function int f(int a);
    if (a > 1) return rep(a);
    return 0;
  endfunction
endpackage
module top;
  import p::*;
  int x;
  initial x = f(2);
endmodule

// § pkgRetCallSharesConstRet457
package p;
  function bit rep(int v); return 1; endfunction
  function int f(int a);
    return rep(a);
  endfunction
endpackage
module top;
  import p::*;
  int x;
  initial x = f(2);
endmodule

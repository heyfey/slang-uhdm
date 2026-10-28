// § pkgRetCallSharesConstRet457
package p;
  function int rep(int v); return 6; endfunction
  function int f(int a);
    return rep(a);
  endfunction
  function int g(int b);
    return rep(b);
  endfunction
endpackage
module top;
  import p::*;
  int x;
  initial x = f(2) + g(3);
endmodule

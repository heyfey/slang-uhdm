// § pkgRetCallSharesConstRet457
package p;
  function int rep(int v); return 3; endfunction
  function int f(int a);
    return rep(2);
  endfunction
endpackage
module top;
  import p::*;
  int x;
  initial x = f(2);
endmodule

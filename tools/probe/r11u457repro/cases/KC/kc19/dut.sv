// § pkgRetCallSharesConstRet457
package p;
  function int rep(int v); return 4'b1x; endfunction
  function int f(int a);
    return rep(a);
  endfunction
endpackage
module top;
  import p::*;
  int x;
  initial x = f(2);
endmodule

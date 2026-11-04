// § pkgRetCallSharesConstRet457
package p;
  function bit rep(int v); return 3; endfunction
  function bit f(int a);
    return rep(a);
  endfunction
endpackage
module top;
  import p::*;
  bit x;
  initial x = f(2);
endmodule

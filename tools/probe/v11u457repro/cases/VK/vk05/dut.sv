// § pkgRetCallSharesConstRet457
package q;
  function int rep(int v); return 4; endfunction
endpackage
package p;
  function int f(int a);
    return q::rep(a);
  endfunction
endpackage
module top;
  import p::*;
  int x;
  initial x = f(2);
endmodule

// § pkgRetCallSharesConstRet457
package p;
  function int rep(int v); return 3; endfunction
  function int f(int a);
    return rep(a);
  endfunction
endpackage
module top;
  import p::*;
  int x;
  initial x = rep(1) + f(2);
  function int m(int z); return rep(z); endfunction
  initial x = m(4);
endmodule

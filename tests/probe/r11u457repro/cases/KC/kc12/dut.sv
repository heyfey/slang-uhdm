// § pkgRetCallSharesConstRet457
package p;
  function bit [7:0] rep(int v); return 3; endfunction
  function int f(int a);
    return rep(a);
  endfunction
endpackage
module top;
  import p::*;
  int x;
  initial x = f(2);
endmodule

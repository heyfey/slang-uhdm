// § pkgRetCallSharesConstRet457
package p;
  typedef int myint_t;
  function myint_t rep(int v); return 7; endfunction
  function int f(int a);
    return rep(a);
  endfunction
endpackage
module top;
  import p::*;
  int x;
  initial x = f(2);
endmodule

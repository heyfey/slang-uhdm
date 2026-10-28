// § pkgRetCallSharesConstRet457
package p;
  function int rep(); int t; return 3; endfunction
  function int f(int a);
    return rep();
  endfunction
endpackage
module top;
  import p::*;
  int x;
  initial x = f(2);
endmodule

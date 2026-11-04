// § pkgRetCallSharesConstRet457
package p;
  function byte rep(); return 300; endfunction
  function int f(int a);
    return rep();
  endfunction
endpackage
module top;
  import p::*;
  int x;
  initial x = f(2);
endmodule

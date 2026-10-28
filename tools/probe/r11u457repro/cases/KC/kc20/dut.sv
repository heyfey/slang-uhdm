// § pkgRetCallSharesConstRet457
package p;
  function int rep(); return 5; endfunction
  function int f(int a);
    return rep() + 1;
  endfunction
endpackage
module top;
  import p::*;
  int x;
  initial x = f(2);
endmodule

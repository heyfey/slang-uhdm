// § pkgRetCallSharesConstRet457
package p;
  function int rep(int v); return 3; endfunction
  class C;
    extern function int f(int a);
  endclass
  function int C::f(int a);
    return rep(a);
  endfunction
endpackage
package q;
  import p::*;
  function int own(int b); return b; endfunction
endpackage
module top;
  import q::*;
  initial $display(own(1));
endmodule

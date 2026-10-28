// § pkgRetCallSharesConstRet457
package p;
  function int rep(int v); return 3; endfunction
  function int f(int a);
    return rep(a);
  endfunction
endpackage
module top(input int i, output int o);
  import p::*;
  assign o = f(i) + i;
endmodule

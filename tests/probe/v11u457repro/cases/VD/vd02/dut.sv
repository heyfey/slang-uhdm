// § pkgRetCallPassArgShare457
package p;
  function int rep(int v); return v; endfunction
  function int f(int a);
    return rep(a);
  endfunction
endpackage
module top(input int i, output int o);
  import p::*;
  assign o = f(i);
endmodule

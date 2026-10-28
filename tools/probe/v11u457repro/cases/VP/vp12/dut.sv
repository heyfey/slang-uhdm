// § pkgRetCallPassArgShare457
package p;
  function int rep(int v); return v; endfunction
  function int f(int a);
    return -rep(a);
  endfunction
  function int g(int a);
    return rep(a) ? 1 : 0;
  endfunction
endpackage
module top;
  import p::*;
  int x;
  initial x = f(2) + g(1);
endmodule

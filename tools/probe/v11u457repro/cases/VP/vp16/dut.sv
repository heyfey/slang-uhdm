// § pkgRetCallPassArgShare457
package p;
  function int rep(int v); return v; endfunction
  function int f(int a);
    return rep(rep(a));
  endfunction
  function int g(int a, int b);
    return rep(b);
  endfunction
endpackage
module top;
  import p::*;
  int x;
  initial x = f(2) + g(3, 4);
endmodule

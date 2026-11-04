// § pkgRetCallPassArgShare457
package p;
  function int rep(int v); return v; endfunction
  function int f(int a);
    int t;
    t = a;
    return rep(t);
  endfunction
endpackage
module top;
  import p::*;
  int x;
  initial x = f(2);
endmodule

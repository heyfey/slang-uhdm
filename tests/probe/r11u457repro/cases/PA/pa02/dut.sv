// § pkgRetCallPassArgShare457
package p;
  function int rep(int v, int w); return w; endfunction
  function int f(int a);
    int k; k = a; return rep(a, k);
  endfunction
endpackage
module top;
  import p::*;
  int x;
  initial x = f(2);
endmodule

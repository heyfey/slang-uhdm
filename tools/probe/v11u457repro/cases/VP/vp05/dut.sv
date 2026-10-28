// § pkgRetCallPassArgShare457
package p;
  int gv;
  function int rep(int v); return v; endfunction
  function int f(int a);
    return rep(gv);
  endfunction
endpackage
module top;
  import p::*;
  int x;
  initial x = f(2);
endmodule

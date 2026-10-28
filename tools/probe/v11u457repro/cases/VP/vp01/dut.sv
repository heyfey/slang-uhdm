// § pkgRetCallPassArgShare457
package p;
  function automatic int rep(ref int v); return v; endfunction
  function automatic int f(int a);
    return rep(a);
  endfunction
endpackage
module top;
  import p::*;
  int x;
  initial x = f(2);
endmodule

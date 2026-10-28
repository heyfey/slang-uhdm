// § pkgRetCallPassArgShare457
package q;
  function int rep(int v); return v; endfunction
endpackage
package p;
  function int f(int a);
    return q::rep(a);
  endfunction
  function int g(int a);
    return f(a) + 1;
  endfunction
endpackage
module top;
  import p::*;
  int x;
  initial x = f(2) + g(3);
endmodule

// § pkgRetCallPassArgShare457
package p;
  function int rep(int v); return v; endfunction
  function int f(int a);
    return rep(a);
  endfunction
  function int g(int a);
    return rep(a);
  endfunction
endpackage
package q;
  import p::*;
  function int own(int b); return b; endfunction
endpackage
module top;
  import q::*;
  import p::*;
  int x;
  initial x = f(2) + g(3) + own(1);
endmodule

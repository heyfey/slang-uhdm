// § pkgRetCallPassArgShare457
package p;
  function logic [3:0] rep(logic [3:0] v); return v; endfunction
  function int f(int a);
    return rep(a);
  endfunction
endpackage
module top;
  import p::*;
  int x;
  initial x = f(2);
endmodule

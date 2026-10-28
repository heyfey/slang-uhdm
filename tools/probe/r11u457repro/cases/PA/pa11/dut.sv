// § pkgRetCallPassArgShare457
package p;
  function int rep(int v); return v; endfunction
  class C;
    extern function int f(int a);
  endclass
  function int C::f(int a);
    return rep(a);
  endfunction
endpackage
package q;
  import p::*;
  class D;
    int k;
  endclass
endpackage
module top;
  import q::*;
  D d;
endmodule

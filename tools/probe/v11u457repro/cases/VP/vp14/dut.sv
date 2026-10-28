// § pkgRetCallPassArgShare457
package p;
  function int rep(int v); return v; endfunction
  class C;
    int m;
    extern function int f(int a);
    extern static function int g(int a);
  endclass
  function int C::f(int a);
    int t;
    t = a;
    return rep(t);
  endfunction
  function int C::g(int a);
    return rep(a);
  endfunction
endpackage
module top;
  import p::*;
  C c;
endmodule

// § shellCallInvocationSpan254 (the receiver a class property, a this. path and a static class-scoped get)
package p;
virtual class wrap; endclass
class fac;
  function bit reg1(wrap r); return 1; endfunction
  function bit reg4(int a, wrap r); return 1; endfunction
  static function fac get(); return null; endfunction
endclass
function automatic int g(bit b); return b; endfunction
class c #(type T=int);
  fac f;
  function void f1();
    T rgtry = 3;
    bit b;
    b = f.reg1(rgtry);
    b = this.f.reg1(rgtry);
    if (this.f.reg1(rgtry)) b = 0;
  endfunction
endclass
endpackage
module top; endmodule

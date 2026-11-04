// § shellCallInvocationSpan254 (two arguments with the bad one second, a named argument, an extra space before the paren)
package p;
virtual class wrap; endclass
class fac;
  function bit reg1(wrap r); return 1; endfunction
  function bit reg4(int a, wrap r); return 1; endfunction
  static function fac get(); return null; endfunction
endclass
function automatic int g(bit b); return b; endfunction
class c #(type T=int);
  static function void f1();
    fac factory = fac::get();
    T rgtry = 3;
    bit b;
    b = factory.reg4(1, rgtry);
    b = factory.reg1(.r(rgtry));
    b = factory.reg1 ( rgtry );
    if (factory.reg4(.a(2), .r(rgtry))) b = 0;
  endfunction
endclass
endpackage
module top; endmodule

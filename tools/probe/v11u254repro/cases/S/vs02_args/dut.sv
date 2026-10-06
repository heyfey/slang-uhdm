// § shellCallInvocationSpan254 (the wrapped call as an argument of a user function and of a system task, and as an operand)
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
    int n;
    n = g(factory.reg1(rgtry));
    $display("%0d", factory.reg1(rgtry));
    n = !factory.reg1(rgtry);
    n = factory.reg1(rgtry) + 1;
    if (factory.reg1(rgtry) == 1'b1) n = 5;
  endfunction
endclass
endpackage
module top; endmodule

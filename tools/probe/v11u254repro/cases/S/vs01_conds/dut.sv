// § shellCallInvocationSpan254 (the wrapped call as a while condition, a ternary condition, a return value and a case expression)
package p;
virtual class wrap; endclass
class fac;
  function bit reg1(wrap r); return 1; endfunction
  function bit reg4(int a, wrap r); return 1; endfunction
  static function fac get(); return null; endfunction
endclass
function automatic int g(bit b); return b; endfunction
class c #(type T=int);
  static function bit f1();
    fac factory = fac::get();
    T rgtry = 3;
    int n;
    while (factory.reg1(rgtry)) n++;
    n = factory.reg1(rgtry) ? 1 : 2;
    case (factory.reg1(rgtry)) 1'b1: n = 3; default: n = 4; endcase
    return factory.reg1(rgtry);
  endfunction
endclass
endpackage
module top; endmodule

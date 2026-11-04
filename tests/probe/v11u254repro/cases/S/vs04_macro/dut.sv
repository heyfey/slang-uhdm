// § shellCallInvocationSpan254 (the wrapped call born in a macro: the whole call, and the arguments only)
`define CHK(x) factory.reg1(x)
`define ARG rgtry
package p;
virtual class wrap; endclass
class fac;
  function bit reg1(wrap r); return 1; endfunction
  static function fac get(); return null; endfunction
endclass
class c #(type T=int);
  static function void f1();
    fac factory = fac::get();
    T rgtry = 3;
    bit b;
    if (`CHK(rgtry)) b = 1;
    b = factory.reg1(`ARG);
  endfunction
endclass
endpackage
module top; endmodule

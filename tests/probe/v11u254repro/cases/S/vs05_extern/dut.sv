// § shellCallInvocationSpan254 (the wrapped call in an extern method defined after the class, in an override of a pure virtual)
package p;
virtual class wrap; endclass
class fac;
  function bit reg1(wrap r); return 1; endfunction
  function bit reg4(int a, wrap r); return 1; endfunction
  static function fac get(); return null; endfunction
endclass
function automatic int g(bit b); return b; endfunction
virtual class base; pure virtual function bit pv(); endclass
class c #(type T=int) extends base;
  extern function bit ex();
  virtual function bit pv();
    fac factory = fac::get();
    T rgtry = 3;
    return factory.reg1(rgtry) && 1'b1;
  endfunction
endclass
function bit c::ex();
  fac factory = fac::get();
  T rgtry = 3;
  if (factory.reg1(rgtry)) return 1;
  return 0;
endfunction
endpackage
module top;
  import p::*;
endmodule

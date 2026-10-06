// § shellCallInvocationSpan254 (fresh: wrapped calls to an extern method defined below the caller, to a pure virtual prototype through a base handle, and with linked and unlinked named arguments)
package p;
virtual class wrap; endclass
virtual class base;
  pure virtual function bit pv(wrap r);
endclass
class fac extends base;
  extern function bit ex(wrap r, int k = 2);
  virtual function bit pv(wrap r); return 1; endfunction
endclass
class c #(type T=int);
  static function void f1(base b, fac f);
    T rgtry;
    bit z;
    if (f.ex(rgtry)) begin end
    z = b.pv(rgtry);
    z = f.ex(.r(rgtry));
    z = f.ex(.k(1), .r(rgtry));
  endfunction
endclass
function bit fac::ex(wrap r, int k = 2); return 1; endfunction
endpackage
module top; endmodule

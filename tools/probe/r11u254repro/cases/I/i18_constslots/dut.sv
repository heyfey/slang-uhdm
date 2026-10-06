// § shellCallInvocationSpan254 (constant slots beside the wrapped call: an indexed part-select base, a part-select with literal bounds)
package p;
virtual class wrap; endclass
class fac;
  function bit reg1(wrap r); return 1; endfunction
  static function fac get(); return null; endfunction
endclass
class c #(type T=int, int W=8);
  static function void f1(string a);
    fac factory = fac::get();
    T rgtry = 3;
    bit [W-1:0] v;
    int x;
    x = v[factory.reg1(rgtry) +: 2];
    x = v[3:0] + factory.reg1(rgtry);
  endfunction
endclass
endpackage
module top; endmodule

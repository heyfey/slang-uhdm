// § shellCallInvocationSpan254 (control: the same calls with a convertible argument, no Invalid shell)
package p;
virtual class wrap; endclass
class fac;
  int arr[4];
  function bit reg1(wrap r); return 1; endfunction
  static function bit reg2(wrap r); return 1; endfunction
  function fac self(); return this; endfunction
  static function fac get(); return null; endfunction
endclass
function automatic bit reg3(wrap r); return 1; endfunction
class c #(type T=wrap);
  static function void f1(string a);
    fac factory = fac::get();
    T rgtry = null;
    bit b;
    if (factory.reg1(rgtry)) begin end
    b = fac::reg2(rgtry);
    b = reg3(rgtry);
    factory.reg1(rgtry);
  endfunction
endclass
endpackage
module top; endmodule

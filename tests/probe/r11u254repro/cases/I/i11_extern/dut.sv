// § shellCallInvocationSpan254 (the wrapped call in an out-of-body (extern) method imported by the top module)
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
class c #(type T=int);
  extern static function void f1(string a);
endclass
function void c::f1(string a);
  fac factory = fac::get();
  T rgtry = 3;
  if (factory.reg1(rgtry)) begin end
endfunction
endpackage
module top; import p::*; endmodule

// § shellCallInvocationSpan254 (a method call wrapped by slang's InvalidExpression, in an if condition)
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
  static function void f1(string a);
    fac factory = fac::get();
    T rgtry = 3;
    if (factory.reg1(rgtry)) begin end
  endfunction
endclass
endpackage
module top; endmodule

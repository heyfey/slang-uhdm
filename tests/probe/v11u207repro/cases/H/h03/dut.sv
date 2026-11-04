// § parenMethodCallPathSpan207: parenthesized class-specialization static calls, parenthesized method calls with a defaulted argument written, in a class bound expression and in a return of a derived class through super
package p;
class K #(int W = 1);
  static function int sf(int a, int b = 3); return a + b + W; endfunction
  function int gi(int a, int b = 2); return a + b; endfunction
endclass
class D extends K #(4);
  int q [8];
  function int gi(int a, int b = 2); return (super.gi(a, b)) + (K#(2)::sf(1, 2)); endfunction
  function int h(K #(4) k); return q[(k.gi(1, 5))] + (k.gi(3, 1)) * 2; endfunction
endclass
endpackage
module top; endmodule

// § parenMethodCallPathSpan207: parenthesized built-in and static method calls: string len, queue size, a static class method, a void cast of a parenthesized method call
package p;
class C;
  int q[$];
  string s;
  static function int sg(int a = 1); return a; endfunction
  function int gi(int a = 0); return a; endfunction
  function int f(C c);
    return (s.len()) + (q.size()) + (C::sg(2)) + (c.gi(3)) * 2;
  endfunction
endclass
endpackage
module top; endmodule

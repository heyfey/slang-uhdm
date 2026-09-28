// § namedUnlinkedWrittenOrder207 (nested named calls, both unresolved: the inner reordered, the outer skipping a default)
package p;
  class F;
    extern function int mt(int a, int b = 1, int c = 2);
    extern function int nx(int x, int y = 5);
    extern function void g(int v);
  endclass
  function void F::g(int v);
    int r;
    r = mt(.c(nx(.y(v), .x(1))), .a(mt(.b(2), .a(v))));
  endfunction
  function int F::mt(int a, int b = 1, int c = 2); return a + b + c; endfunction
  function int F::nx(int x, int y = 5); return x * y; endfunction
endpackage
module top; endmodule

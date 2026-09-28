// § namedUnlinkedWrittenOrder207: a mixed positional and named list to an extern function (declined: the prefix rule) and a named call inside another call's argument
package p;
class F;
  extern function int mt(int a, int b = 1, int c = 2);
  extern function void g(int x);
endclass
function void F::g(int x);
  int r;
  r = mt(x, .c(4));
  r = mt(.a(mt(.c(1), .a(x))), .c(3));
endfunction
function int F::mt(int a, int b = 1, int c = 2);
  return a + b + c;
endfunction
endpackage
module top; endmodule

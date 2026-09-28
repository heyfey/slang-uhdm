// § namedUnlinkedWrittenOrder207: controls the law declines: an empty named argument, a duplicate-free complete list in formal order, a positional list with a skipped default, and a named call to an in-body method declared above
package p;
class F;
  function int above(int a, int b = 1, int c = 2); return a; endfunction
  extern function int mt(int a, int b = 1, int c = 2);
  extern function void g(int x);
endclass
function void F::g(int x);
  int r;
  r = mt(.a(x), .b(), .c(1));
  r = mt(.a(x), .b(2), .c(1));
  r = mt(x, 2);
  r = mt(.a(x), .b(3));
  r = above(.c(5), .a(x));
endfunction
function int F::mt(int a, int b = 1, int c = 2);
  return a + b + c;
endfunction
endpackage
module top; endmodule

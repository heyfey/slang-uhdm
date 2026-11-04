// § namedUnlinkedWrittenOrder207: named arguments written out of formal order to an extern function compiled later
package p;
class F;
  extern function int mt(int a, int b, int c = 3);
  extern function void g(int x);
endclass
function void F::g(int x);
  int r;
  r = mt(.b(x), .a(2));
  r = mt(.c(x + 1), .a(1), .b(x));
  r = mt(.a(1), .c(5), .b(x));
endfunction
function int F::mt(int a, int b, int c = 3);
  return a + b + c;
endfunction
endpackage
module top; endmodule

// § namedUnlinkedWrittenOrder207: extern methods called before their bodies with named arguments in a loop condition, as an index, as a return value and as an argument of a system call
package p;
class F;
  int m[int];
  extern function int mt(int a, int b = 1, int c = 2);
  extern function int g(int x);
  extern static function int s(int a, int b = 3, int c = 4);
endclass
function int F::g(int x);
  for (int i = 0; i < mt(.c(x), .a(1)); i++) x++;
  x += m[mt(.a(x), .c(0))];
  $display("%0d", mt(.b(x), .a(2)));
  x += F::s(.c(1), .a(x));
  return mt(.c(x), .b(2), .a(3));
endfunction
function int F::mt(int a, int b = 1, int c = 2);
  return a + b + c;
endfunction
function int F::s(int a, int b = 3, int c = 4);
  return a;
endfunction
endpackage
module top; endmodule

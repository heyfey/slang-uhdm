// § namedOrderLinkedDeclines207v (refines § namedUnlinkedWrittenOrder207): a class property initializer and a constraint-free static initializer calling an extern method with named arguments; a parameterized class calling its own extern method
package p;
class F #(int W = 4);
  extern static function int mt(int a, int b = W, int c = 2);
  static int s = mt(.c(7), .a(1));
  function int g(); return mt(.c(W), .b(1), .a(0)); endfunction
endclass
function int F::mt(int a, int b = W, int c = 2);
  return a + b + c;
endfunction
endpackage
module top(output int o);
  p::F #(8) h;
  initial begin h = new; o = h.g(); end
endmodule

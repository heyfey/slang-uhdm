// § namedUnlinkedWrittenOrder207 (an extern function called before its out-of-block body, the body in an included file)
package p;
  class F;
    extern function int mt(int a, int b = 1, int c = 2);
    extern function int g(int x);
  endclass
  function int F::g(int x);
    return mt(.c(x), .a(1)) + mt(.b(x), .a(0));
  endfunction
  `include "mt_body.svh"
endpackage
module top; endmodule

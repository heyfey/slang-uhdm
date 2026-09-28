// § namedOrderLinkedDeclines207v § namedUnlinkedWrittenOrder207 (an extern FUNCTION prototype from an included header above the in-body caller; control of the function half)
package p;
  class F;
    `include "fproto.svh"
    function int g(int x);
      return mt(.c(x), .b(2), .a(1));
    endfunction
  endclass
  function int F::mt(int a, int b = 1, int c = 2); return a + b + c; endfunction
endpackage
module top; endmodule

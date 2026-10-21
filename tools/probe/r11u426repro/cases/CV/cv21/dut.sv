// § namedTypeLocalTfItemOutsideClass426
package p;
  typedef struct { int a; } box_t;
  function integer test;
    box_t r;
    test = r.a;
  endfunction
endpackage
module top;
  import p::*;
  initial $display(test());
endmodule

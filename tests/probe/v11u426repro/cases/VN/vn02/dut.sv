// § namedTypeLocalTfItemOutsideClass426
package p;
  typedef struct { int a; } box_t;
endpackage
module top;
  function integer f;
    p::box_t r;
    r.a = 1;
    f = r.a;
  endfunction
  initial $display(f());
endmodule

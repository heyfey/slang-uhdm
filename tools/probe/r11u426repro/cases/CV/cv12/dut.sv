// § namedTypeLocalTfItemOutsideClass426
typedef struct { int a; } box_t;
module top;
  function integer test;
    box_t r;
    test = r.a;
  endfunction
endmodule

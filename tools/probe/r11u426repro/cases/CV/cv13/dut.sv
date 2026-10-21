// § namedTypeLocalTfItemOutsideClass426
typedef struct { int a; } box_t;
function integer test;
  box_t r;
  test = r.a;
endfunction
module top;
endmodule

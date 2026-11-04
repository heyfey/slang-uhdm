// § namedTypeLocalTfItemOutsideClass426
typedef struct { int a; } box_t;
module top;
  function integer f;
    input int i;
    box_t r;
    r.a = i;
    f = r.a;
  endfunction
  initial $display(f(2));
endmodule

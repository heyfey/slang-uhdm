// § namedTypeLocalTfItemOutsideClass426
typedef struct { int a; } box_t;
module top;
  function integer f;
    box_t r [2];
    r[0].a = 1;
    f = r[0].a;
  endfunction
  initial $display(f());
endmodule

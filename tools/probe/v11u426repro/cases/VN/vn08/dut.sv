// § namedTypeLocalTfItemOutsideClass426
typedef struct { int a; } box_t;
module top;
  function integer f;
    box_t r1, r2;
    int k;
    r1.a = 1; r2.a = 2; k = 3;
    f = r1.a + r2.a + k;
  endfunction
  initial $display(f());
endmodule

// § namedTypeLocalTfItemOutsideClass426
typedef struct { int a; } box_t;
module top;
  function static integer f;
    box_t r;
    r.a = 1;
    f = r.a;
  endfunction
  initial $display(f());
endmodule

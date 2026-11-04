// § namedTypeLocalTfItemOutsideClass426
typedef enum {R, G} col_t;
module top;
  function integer f;
    col_t c [2];
    col_t d;
    c[0] = R; d = G;
    f = c[0] + d;
  endfunction
  initial $display(f());
endmodule

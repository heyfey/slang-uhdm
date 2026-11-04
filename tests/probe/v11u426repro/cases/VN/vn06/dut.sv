// § namedTypeLocalTfItemOutsideClass426
typedef logic [3:0] nib_t;
typedef struct packed { logic [3:0] a; logic [3:0] b; } pair_t;
module top(input logic [7:0] i, output logic [7:0] o);
  function logic [7:0] swap;
    input logic [7:0] x;
    pair_t p;
    nib_t n;
    p = x;
    n = p.a;
    p.a = p.b;
    p.b = n;
    swap = p;
  endfunction
  assign o = swap(i);
endmodule

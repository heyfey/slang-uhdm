// § namedTypeLocalTfItemOutsideClass426
typedef struct packed { logic [3:0] a; logic [3:0] b; } pair_t;
module top(input logic [7:0] i, output logic [7:0] o);
  task automatic sw;
    input logic [7:0] x;
    output logic [7:0] y;
    pair_t p;
    p = x;
    y = {p.b, p.a};
  endtask
  always_comb sw(i, o);
endmodule

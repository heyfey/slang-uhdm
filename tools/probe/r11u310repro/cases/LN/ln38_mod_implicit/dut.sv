// § lvNestShapeMidIdxAtSel310
typedef struct packed { logic [3:0] k; logic [3:0] j; } t_t;
typedef struct packed { logic [3:0] k; t_t [3:0] a; } u_t;
typedef struct packed { logic [7:0] f; } e_t;
module sub(input logic [1:0] p, output logic [1:0] q); assign q = p; endmodule
module top(input logic clk, input logic [1:0] i, input logic [7:0] d, output logic [7:0] r);
  e_t sa [16]; u_t u;
  sub s(.p(i), .q(w));
  always_ff @(posedge clk) sa[u.a[w].k].f <= d;
  assign r = sa[0].f;
endmodule

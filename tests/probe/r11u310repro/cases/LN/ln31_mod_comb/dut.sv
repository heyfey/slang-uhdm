// § lvNestShapeMidIdxAtSel310
typedef struct packed { logic [3:0] k; logic [3:0] j; } t_t;
typedef struct packed { logic [3:0] k; t_t [3:0] a; } u_t;
typedef struct packed { logic [7:0] f; } e_t;
module top(input logic [1:0] i, input logic [7:0] d, output logic [7:0] r);
  e_t sa [16]; u_t u;
  always_comb begin sa[u.a[i].k].f = d; sa[u.a[i + 1].j].f = d; end
  assign r = sa[0].f;
endmodule

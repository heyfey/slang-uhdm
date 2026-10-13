// § lvNestShapeMidIdxAtSel310
typedef struct packed { logic [3:0] k; logic [3:0] j; } t_t;
typedef struct packed { logic [3:0] k; t_t [3:0] a; } u_t;
typedef struct packed { logic [7:0] f; } e_t;
interface ifc(input logic clk);
  e_t sa [16]; u_t u; logic [1:0] i; logic [7:0] d;
  always_ff @(posedge clk) sa[u.a[i].k].f <= d;
endinterface
module top(input logic clk, output logic [7:0] r);
  ifc x(clk);
  assign r = x.sa[0].f;
endmodule

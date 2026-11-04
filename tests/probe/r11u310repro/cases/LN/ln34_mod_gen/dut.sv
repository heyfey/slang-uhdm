// § lvNestShapeMidIdxAtSel310
typedef struct packed { logic [3:0] k; logic [3:0] j; } t_t;
typedef struct packed { logic [3:0] k; t_t [3:0] a; } u_t;
typedef struct packed { logic [7:0] f; } e_t;
module top(input logic clk, input logic [7:0] d, output logic [7:0] r);
  e_t sa [16]; u_t u;
  for (genvar g = 0; g < 2; g++) begin : gb
    always_ff @(posedge clk) sa[u.a[g].k].f <= d;
  end
  if (1) begin : gi
    always_ff @(posedge clk) sa[u.a[2].j].f <= d;
  end
  assign r = sa[0].f;
endmodule

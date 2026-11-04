// § lvMemberSelIdxKeepsRead308
typedef struct packed { logic [3:0] k; logic [3:0] j; logic [3:0][3:0] idx; } t_t;
typedef struct packed { logic [3:0] k; t_t [1:0] a; } u_t;
typedef struct packed { logic [7:0] f; logic [3:0][7:0] g; } e_t;
typedef struct { e_t arr[4]; logic [3:0] k; } h_t;
module top(input logic clk, output logic [7:0] r);
  h_t hv; t_t t; u_t u;
  always_comb begin hv.arr[0].f = 0; hv.arr[t.k].f = 8'd1; hv.arr[u.a[1].k].g[0] = 8'd2; end
  always_ff @(posedge clk) hv.arr[t.j].f <= 8'd3;
  assign r = hv.arr[0].f;
endmodule

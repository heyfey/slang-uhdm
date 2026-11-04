// § lvNestShapeMidIdxAtSel310
package p; localparam int N = 1; function automatic int f(int x); return x; endfunction endpackage
typedef struct packed { logic [1:0] f; logic [1:0] k; } e_t;
typedef struct packed { e_t [3:0] a; } u_t;
module top(input logic clk, input logic [1:0] i); e_t [3:0] sa; u_t u; assign w = i[0];
  always_ff @(posedge clk) sa[u.a[w].k].f <= 0; endmodule

// § nonTrailIdxPathNestShape306
typedef struct packed { logic [3:0] k; logic [3:0] j; logic [3:0][3:0] idx; } t_t;
typedef struct packed { logic [7:0] f; logic [3:0][7:0] g; } e_t;

module top(input logic clk, input logic [3:0] i, output logic [7:0] r, output logic [7:0] r2);
  e_t sa [16]; t_t t; t_t ta[4]; logic [3:0] m[16]; logic [3:0] m2[4][4];
  localparam t_t LP = '{k: 4'd2, j: 4'd1, idx: '0}; assign r = sa[LP.k].f;
endmodule

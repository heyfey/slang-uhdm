// § nonTrailIdxPathNestShape306
typedef struct packed { logic [3:0] k; logic [3:0] j; logic [3:0][3:0] idx; } t_t;
typedef struct packed { logic [7:0] f; logic [3:0][7:0] g; } e_t;
typedef struct { logic [3:0] k; } us_t;
module top(input logic clk, input logic [3:0] i, output logic [7:0] r, output logic [7:0] r2);
  e_t sa [16]; t_t t; t_t ta[4]; logic [3:0] m[16]; logic [3:0] m2[4][4];
  us_t ut; assign r = sa[ut.k].f;
endmodule

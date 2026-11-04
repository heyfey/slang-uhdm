// § nonTrailSelNestedSelWhole306
typedef struct packed { logic [3:0] k; logic [3:0] j; logic [3:0][3:0] idx; } t_t;
typedef struct packed { logic [7:0] f; logic [3:0][7:0] g; } e_t;
module top(input logic [1:0] i, output logic [7:0] r);
  e_t sa [4]; logic [1:0] m [4];
  assign r = sa[m[m[i]]].f;
endmodule

// § nonTrailIdxPathNestShape306
typedef struct packed { logic [3:0] k; logic [3:0] j; logic [3:0][3:0] idx; } t_t;
typedef struct packed { logic [7:0] f; logic [3:0][7:0] g; } e_t;
module top(output logic [7:0] r);
  e_t sa [16]; t_t t;
  assign r = sa[t.k].f;
endmodule

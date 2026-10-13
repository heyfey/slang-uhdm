// § nonTrailIdxPathNestShape306
package pk;
  typedef struct packed { logic [3:0] k; logic [3:0] j; } t_t;
  t_t pt;
endpackage
typedef struct packed { logic [7:0] f; logic [3:0][7:0] g; } e_t;
module top(output logic [7:0] r);
  e_t sa [16];
  assign r = sa[pk::pt.k].f;
endmodule

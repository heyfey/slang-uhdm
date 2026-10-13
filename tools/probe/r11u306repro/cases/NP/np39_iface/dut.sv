// § nonTrailIdxPathNestShape306
typedef struct packed { logic [3:0] k; logic [3:0] j; logic [3:0][3:0] idx; } t_t;
typedef struct packed { logic [7:0] f; logic [3:0][7:0] g; } e_t;
interface ifc; e_t sa [16]; t_t t; logic [7:0] o; assign o = sa[t.k].f; endinterface
module top(output logic [7:0] r);
  ifc u();
  assign r = u.o;
endmodule

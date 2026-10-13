// § nonTrailIdxPathNestShape306
typedef struct packed { logic [3:0] k; } t_t;
typedef struct packed { logic [7:0] f; } e_t;
interface ifc; e_t sa [16]; endinterface
module top(input t_t t, output logic [7:0] r);
  ifc u();
  assign r = u.sa[t.k].f;
endmodule

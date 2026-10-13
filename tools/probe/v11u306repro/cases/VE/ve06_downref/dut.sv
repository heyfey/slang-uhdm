// § nonTrailIdxPathNestShape306
typedef struct packed { logic [3:0] k; } t_t;
typedef struct packed { logic [7:0] f; } e_t;
module sub; e_t sa [16]; endmodule
module top(input t_t t, output logic [7:0] r);
  sub s();
  assign r = s.sa[t.k].f;
endmodule

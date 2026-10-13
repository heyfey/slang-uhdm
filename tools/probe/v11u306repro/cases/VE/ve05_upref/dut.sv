// § nonTrailIdxPathNestShape306
typedef struct packed { logic [3:0] k; } t_t;
typedef struct packed { logic [7:0] f; } e_t;
module sub(input t_t t, output logic [7:0] r);
  assign r = top.sa[t.k].f;
endmodule
module top(input t_t t, output logic [7:0] r);
  e_t sa [16];
  sub s(.t(t), .r(r));
endmodule

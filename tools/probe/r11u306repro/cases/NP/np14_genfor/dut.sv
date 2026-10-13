// § nonTrailIdxPathNestShape306
typedef struct packed { logic [3:0] k; logic [3:0] j; logic [3:0][3:0] idx; } t_t;
typedef struct packed { logic [7:0] f; logic [3:0][7:0] g; } e_t;
module top(output logic [7:0] r [2]);
  e_t sa [16]; t_t t;
  for (genvar gg = 0; gg < 2; gg++) begin : gb
    assign r[gg] = sa[t.idx[gg]].f;
  end
endmodule

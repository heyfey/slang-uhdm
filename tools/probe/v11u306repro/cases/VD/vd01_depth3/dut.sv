// § nonTrailIdxPathNestShape306
typedef struct packed { logic [3:0] k; logic [3:0] j; logic [3:0][3:0] idx; } t_t;
typedef struct packed { logic [7:0] f; logic [3:0][7:0] g; } e_t;
module leaf(input t_t t, output logic [7:0] r, output logic [7:0] r2);
  e_t sa [16];
  assign r = sa[t.idx[1]].f;
  assign r2 = sa[t.k].f;
endmodule
module mid(input t_t t, output logic [7:0] r);
  logic [7:0] x1, x2, y1, y2;
  leaf l1(.t(t), .r(x1), .r2(y1));
  leaf l2(.t(t), .r(x2), .r2(y2));
  assign r = x1 ^ x2 ^ y1 ^ y2;
endmodule
module top(input t_t t, output logic [7:0] r);
  mid m(.t(t), .r(r));
endmodule

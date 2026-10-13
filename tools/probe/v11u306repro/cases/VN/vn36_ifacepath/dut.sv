// § nonTrailIdxPathNestShape306
typedef struct packed { logic [7:0] f; logic [3:0][7:0] g; } e_t;
interface ifc; logic [3:0] k; endinterface
module sub(ifc p, output logic [7:0] r);
  e_t sa [16];
  assign r = sa[p.k].f;
endmodule
module top(output logic [7:0] r);
  ifc u();
  sub s(.p(u), .r(r));
endmodule

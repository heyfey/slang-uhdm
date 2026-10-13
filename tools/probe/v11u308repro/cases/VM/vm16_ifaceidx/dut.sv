// § nonTrailIdxNamesByChain308
interface ifc; logic [3:0] k; logic [7:0] arr [16]; endinterface
typedef struct packed { logic [7:0] f; } e_t;
module top(output logic [7:0] r);
  ifc ii(); e_t sa[16];
  assign r = sa[ii.k + 1].f;
endmodule

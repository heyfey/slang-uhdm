// § nonTrailIdxNamesByChain308
typedef struct packed { logic [7:0] f; } e_t;
interface ifc; e_t sa[16]; logic [3:0] k; logic [3:0] m[16]; endinterface
module sub(ifc p, input logic [3:0] i, output logic [7:0] r);
  assign r = p.sa[p.m[i] + 1].f;
  always_comb p.sa[i + 2].f = 8'd1;
endmodule
module top(input logic [3:0] i, output logic [7:0] r); ifc u(); sub s(.p(u), .i(i), .r(r)); endmodule

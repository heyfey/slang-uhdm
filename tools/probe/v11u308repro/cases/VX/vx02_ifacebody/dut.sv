// § nonTrailIdxNamesByChain308
typedef struct packed { logic [7:0] f; } e_t;
interface ifc(input logic [3:0] i);
  e_t sa[16]; logic [7:0] r; logic [3:0] m[16];
  assign r = sa[m[i] + 1].f;
  always_comb sa[i + 1].f = 8'd1;
endinterface
module top(input logic [3:0] i); ifc u(i); endmodule

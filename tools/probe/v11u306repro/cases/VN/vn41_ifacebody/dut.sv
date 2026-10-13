// § nonTrailIdxPathNestShape306
typedef struct packed { logic [3:0] k; } t_t;
typedef struct packed { logic [7:0] f; } e_t;
interface ifc(input logic [3:0] i);
  e_t sa [16]; t_t t; logic [7:0] r;
  always_comb r = sa[t.k].f;
endinterface
module top(input logic [3:0] i); ifc u(i); endmodule

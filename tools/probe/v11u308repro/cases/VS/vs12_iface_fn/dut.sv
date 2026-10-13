// § nonTrailIdxNamesByChain308
typedef struct packed { logic [7:0] f; } e_t;
interface ifc(input logic [3:0] i);
  e_t sa[16]; logic [7:0] r; logic [3:0] m[16];
  function automatic logic [7:0] g(); return sa[m[i] + 1].f; endfunction
  assign r = g();
endinterface
module top(input logic [3:0] i); ifc u(i); endmodule

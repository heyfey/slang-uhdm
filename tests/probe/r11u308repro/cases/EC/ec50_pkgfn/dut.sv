// § elabClsNonTrailIdxUnstored308
package p;
  typedef struct packed { logic [7:0] f; } s_t;
  function automatic logic [7:0] pf(s_t a [4], int i); return a[i+1].f; endfunction
endpackage
module top(output logic [7:0] o); import p::*; s_t x [4]; assign o = pf(x, 1); endmodule

// § elabClsNonTrailIdxUnstored308
typedef struct packed { logic [7:0] f; } e_t;
module top(input logic [3:0] i, output logic [7:0] r);
  e_t sa[16]; logic [3:0] m[16];
  function automatic void probe(); sa[m[i] + 1].f = 8'd2; endfunction
  initial probe();
  assign r = sa[i].f;
endmodule

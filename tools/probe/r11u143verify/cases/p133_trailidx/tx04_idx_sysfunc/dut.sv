// § hpTrailSelIdxNamesByPath133
// case tx04: trailing select index under a system function
package p;
  typedef struct packed { logic valid; logic [3:0] sat; } e_t;
endpackage
module dut(input logic [1:0] r, input logic [1:0] i, input logic [9:0] flat, output logic o);
  p::e_t [1:0] tbl;
  assign tbl = flat;
  assign o = tbl[r].sat[$unsigned(i)];
endmodule

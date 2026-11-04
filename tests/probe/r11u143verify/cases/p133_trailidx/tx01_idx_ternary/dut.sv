// § hpTrailSelIdxNamesByPath133
// case tx01: trailing select index is a ternary
package p;
  typedef struct packed { logic valid; logic [3:0] sat; } e_t;
endpackage
module dut(input logic [1:0] r, input logic c, input logic [1:0] i, input logic [1:0] j, input logic [9:0] flat, output logic o);
  p::e_t [1:0] tbl;
  assign tbl = flat;
  assign o = tbl[r].sat[c ? i : j];
endmodule

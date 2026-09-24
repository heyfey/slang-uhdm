// § hpTrailSelIdxNamesByPath133
// case tx03: trailing select index is a module-level int variable, in always_comb
package p;
  typedef struct packed { logic valid; logic [3:0] sat; } e_t;
endpackage
module dut(input logic [1:0] r, input logic [9:0] flat, output logic o);
  p::e_t [1:0] tbl;
  int k;
  assign tbl = flat;
  assign k = 2;
  always_comb o = tbl[r].sat[k];
endmodule

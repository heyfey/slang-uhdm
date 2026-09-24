// § hpTrailSelIdxNamesByPath133
// case tx06: a trailing INDEXED part-select with a variable start
package p;
  typedef struct packed { logic valid; logic [3:0] sat; } e_t;
  typedef struct packed { e_t f; logic [1:0] tag; } w_t;
endpackage
module dut(input logic [1:0] r, input logic [1:0] i, input logic [15:0] flat, output logic [1:0] o);
  p::w_t [1:0] tbl;
  assign tbl = flat;
  assign o = tbl[r].f.sat[i +: 2];
endmodule

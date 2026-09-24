// § hpTrailSelIdxNamesByPath133 + § caLhsDefNetUnlessOpRhs139 (cross-ground pair)
// case x03: a trailing-select right-hand side in a sub-module (non-operation right-hand side)
package p;
  typedef struct packed { logic valid; logic [3:0] sat; } e_t;
endpackage
module sub(input logic [1:0] r, input logic [1:0] i, input logic [9:0] flat, output logic y);
  p::e_t [1:0] tbl;
  assign tbl = flat;
  assign y = tbl[r].sat[i];
endmodule
module dut(input logic [1:0] r, input logic [1:0] i, input logic [9:0] flat, output logic y);
  sub u(.r(r), .i(i), .flat(flat), .y(y));
endmodule

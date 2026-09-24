// § hpTrailSelIdxNamesByPath133 + § ndaLeftmostLeafElab139 (cross-ground pair)
// case x01: a trailing-select path as the leftmost leaf of a net declaration assignment
package p;
  typedef struct packed { logic valid; logic [3:0] sat; } e_t;
endpackage
module dut(input logic [1:0] r, input logic [1:0] i, input logic b, input logic [9:0] flat, output logic y);
  p::e_t [1:0] tbl;
  assign tbl = flat;
  wire w = tbl[r].sat[i] ^ b;
  assign y = w;
endmodule

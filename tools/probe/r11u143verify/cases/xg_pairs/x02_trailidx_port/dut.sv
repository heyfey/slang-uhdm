// § hpTrailSelIdxNamesByPath133 + § connLeftmostLeafElab139 (cross-ground pair)
// case x02: a trailing-select path inside an operation port actual
package p;
  typedef struct packed { logic valid; logic [3:0] sat; } e_t;
endpackage
module sub(input logic a, output logic y); assign y = a; endmodule
module dut(input logic [1:0] r, input logic [1:0] i, input logic q, input logic [9:0] flat, output logic y);
  p::e_t [1:0] tbl;
  assign tbl = flat;
  sub u(.a(q & tbl[r].sat[i]), .y(y));
endmodule

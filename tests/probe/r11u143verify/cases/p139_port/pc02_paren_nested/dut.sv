// § connLeftmostLeafElab139
// case pc02: a parenthesized nested operation actual
module sub(input logic a, output logic y); assign y = a; endmodule
module top(input logic p, input logic q, input logic r, output logic y);
  sub u(.a((p | q) & r), .y(y));
endmodule

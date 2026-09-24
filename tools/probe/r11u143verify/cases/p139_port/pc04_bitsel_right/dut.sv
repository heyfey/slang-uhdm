// § connLeftmostLeafElab139
// case pc04: an operation actual whose right operand is a bit-select
module sub(input logic a, output logic y); assign y = a; endmodule
module top(input logic p, input logic [1:0] q, output logic y);
  sub u(.a(p + q[1]), .y(y));
endmodule

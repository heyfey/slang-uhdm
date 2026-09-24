// § connLeftmostLeafElab139
// case pc01: an operation actual on an array of instances
module sub(input logic a, output logic y); assign y = ~a; endmodule
module top(input logic [1:0] p, input logic [1:0] q, output logic [1:0] y);
  sub u[1:0](.a(p & q), .y(y));
endmodule

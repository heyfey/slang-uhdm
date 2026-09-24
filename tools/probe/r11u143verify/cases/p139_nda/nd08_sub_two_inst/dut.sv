// § ndaLeftmostLeafElab139
// case nd08: a net declaration assignment in a sub-module instantiated twice
module sub(input logic a, input logic b, output logic y);
  wire w = a ^ b;
  assign y = w;
endmodule
module top(input logic a, input logic b, output logic y1, output logic y2);
  sub u1(.a(a), .b(b), .y(y1));
  sub u2(.a(b), .b(a), .y(y2));
endmodule

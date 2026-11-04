// § ndaLeftmostLeafElab139
module sub(input logic s, input logic a, input logic b, output logic y, output logic z);
  wire t = s ? a : b;
  wire u = ~a & b;
  assign y = t;
  assign z = u;
endmodule
module top(input logic s, a, b, output logic y, z);
  sub u(.s(s), .a(a), .b(b), .y(y), .z(z));
endmodule

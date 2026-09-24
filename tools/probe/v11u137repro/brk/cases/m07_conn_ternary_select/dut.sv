// § connLeftmostLeafElab139
module sub(input logic a, output logic b);
  assign b = a;
endmodule
module top(input logic s, input logic [3:0] v, output logic y1, y2);
  sub u1(.a(s ? v[1] : v[2]), .b(y1));
  sub u2(.a(v[s] & v[0]), .b(y2));
endmodule

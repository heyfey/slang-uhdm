// § connLeftmostLeafElab139
module sub(input logic a, output logic b);
  assign b = a;
endmodule
module top(input logic p, q, r, output logic y1, y2);
  sub u1(.a(p & q | r), .b(y1));
  if (1) begin : g
    sub u2(.a(q ^ r), .b(y2));
  end
endmodule

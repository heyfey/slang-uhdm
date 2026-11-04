// § oneTickUpperBNormalized425
module sub #(parameter P = 1'B1) (input logic a, output logic y);
  assign y = a ^ P;
endmodule
module top(input logic a, output logic y1, output logic y2);
  sub #(.P(1'B0)) u1(.a(a), .y(y1));
  sub u2(.a(a), .y(y2));
endmodule

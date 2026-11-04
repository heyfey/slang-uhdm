// § unsignedScalarVecTsAtKeyword137
module sub(input wire logic unsigned a, output wire logic unsigned b);
  assign b = a;
endmodule
module top(input logic x, output logic y);
  sub u(.a(x), .b(y));
endmodule

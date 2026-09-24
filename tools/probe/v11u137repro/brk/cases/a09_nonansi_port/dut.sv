// § unsignedScalarVecTsAtKeyword137
module sub(a, b);
  input bit unsigned a;
  output logic unsigned b;
  assign b = a;
endmodule
module top(input logic x, output logic y);
  sub u(.a(x), .b(y));
endmodule

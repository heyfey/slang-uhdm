// § unsignedScalarVecTsAtKeyword137
module sub(a, b);
  input a;
  output b;
  wire logic unsigned a;
  wire logic unsigned b;
  assign b = a;
endmodule
module top(input logic x, output logic y);
  sub u(.a(x), .b(y));
endmodule

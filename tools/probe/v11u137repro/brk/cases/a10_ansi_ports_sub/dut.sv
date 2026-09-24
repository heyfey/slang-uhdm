// § unsignedScalarVecTsAtKeyword137
module sub(input bit unsigned a, input logic unsigned c, output logic unsigned b);
  assign b = a ^ c;
endmodule
module top(input logic x, output logic y);
  sub u(.a(x), .c(x), .b(y));
endmodule

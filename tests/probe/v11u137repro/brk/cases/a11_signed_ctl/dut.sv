// § unsignedScalarVecTsAtKeyword137
module top(output logic o);
  bit signed a;
  logic signed b;
  int unsigned c;
  byte unsigned d;
  assign o = a ^ b ^ c[0] ^ d[0];
endmodule

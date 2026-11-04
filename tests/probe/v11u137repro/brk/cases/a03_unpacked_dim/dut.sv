// § unsignedScalarVecTsAtKeyword137
module top(output logic o);
  logic unsigned x [3:0];
  bit unsigned y [2];
  assign o = x[0] ^ y[1];
endmodule

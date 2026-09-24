// § unsignedScalarVecTsAtKeyword137
// case us01: scalar bit unsigned and logic unsigned with unpacked dimensions
module top(input logic i, output logic o);
  bit unsigned mem [4];
  logic unsigned q [0:1];
  assign q[0] = i;
  assign o = q[0];
endmodule

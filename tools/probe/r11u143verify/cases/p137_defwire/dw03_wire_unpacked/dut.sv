// § unsignedScalarVecTsAtKeyword137 (refinement R11V137_DEFWIRE_OFF)
// case dw03: a wire logic unsigned body net with an unpacked dimension
module top(input logic i, output logic o);
  wire logic unsigned m [2];
  assign m[0] = i;
  assign m[1] = ~i;
  assign o = m[1];
endmodule

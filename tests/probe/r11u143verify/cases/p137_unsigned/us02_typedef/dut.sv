// § unsignedScalarVecTsAtKeyword137
// case us02: a typedef of a scalar bit unsigned, used by a net and a variable
module top(input logic i, output logic o);
  typedef bit unsigned b_t;
  typedef logic unsigned l_t;
  b_t v;
  l_t w;
  assign w = i;
  assign o = w;
endmodule

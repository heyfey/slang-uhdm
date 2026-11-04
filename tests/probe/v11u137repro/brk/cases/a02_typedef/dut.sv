// § unsignedScalarVecTsAtKeyword137
module top(output logic o);
  typedef bit unsigned ub_t;
  typedef logic unsigned ul_t;
  ub_t x;
  ul_t y;
  assign o = x ^ y;
endmodule

// § unsignedScalarVecTsAtKeyword137
package p;
  typedef bit unsigned pb_t;
  bit unsigned pv;
endpackage
module top(output logic o);
  p::pb_t x;
  assign o = x ^ p::pv;
endmodule

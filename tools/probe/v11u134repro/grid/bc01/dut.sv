// § defNetScopedPkgVecTdShares134
package p;
  typedef logic [7:0] byte_t;
  typedef logic signed [3:0] s4_t;
endpackage
module m1(input logic c, output logic [7:0] o);
  p::byte_t v = 8'hA5;
  assign o = v ^ {8{c}};
endmodule
module top(input logic c, output logic [7:0] o, output logic [3:0] o2);
  p::byte_t w [2];
  p::s4_t z;
  assign w[0] = {8{c}};
  assign z = 4'sd3;
  m1 u(.c(c), .o(o));
  assign o2 = w[0][3:0] ^ z;
endmodule

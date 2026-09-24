// § defNetScopedPkgVecTdShares134
package p;
  typedef logic [7:0] byte_t;
endpackage
module top(input logic [7:0] i, output logic [7:0] o);
  p::byte_t v = 8'h11, w = 8'h22;
  p::byte_t z;
  assign z = i;
  assign o = v ^ w ^ z;
endmodule

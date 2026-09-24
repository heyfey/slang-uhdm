// § defNetScopedPkgVecTdShares134
// case k01: a package-scoped vector typedef net with an unpacked dimension
package p;
  typedef logic [7:0] byte_t;
endpackage
module top(output logic [7:0] o);
  p::byte_t v [2];
  assign v[0] = 8'h5C;
  assign o = v[0];
endmodule

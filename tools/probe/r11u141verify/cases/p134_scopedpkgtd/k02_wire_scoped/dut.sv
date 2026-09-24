// § defNetScopedPkgVecTdShares134
// case k02: a wire typed by a package-scoped vector typedef with an initializer
package p;
  typedef logic [7:0] byte_t;
endpackage
module top(output logic [7:0] o);
  wire p::byte_t w = 8'h3A;
  assign o = w;
endmodule

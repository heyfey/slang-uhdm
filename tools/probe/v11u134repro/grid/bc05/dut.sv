// § defNetScopedPkgVecTdShares134
package p;
  typedef logic [3:0] nib_t;
  typedef nib_t [1:0] byte_t;
endpackage
module top(input logic [7:0] i, output logic [7:0] o);
  p::byte_t v;
  p::nib_t n = 4'h3;
  assign v = i;
  assign o = v ^ {n, n};
endmodule

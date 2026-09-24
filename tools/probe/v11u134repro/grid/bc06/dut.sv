// § defNetScopedPkgVecTdShares134
package p;
  typedef logic [7:0] byte_t;
endpackage
module sub(input p::byte_t a, output p::byte_t b);
  p::byte_t t = 8'h0F;
  assign b = a ^ t;
endmodule
module top(input logic [7:0] i, output logic [7:0] o);
  p::byte_t q;
  sub s(.a(i), .b(q));
  assign o = q;
endmodule

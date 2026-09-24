// v93 A6 — 1..3 instances of the same slice-size-bearing module.
module leaf6(input logic [63:0] v, output logic [63:0] r);
  typedef logic [7:0] u6;
  logic [63:0] a, b;
  always_comb a = { << int { v } };
  always_comb b = { << u6  { v } };
  always_comb r = a ^ b;
endmodule
module a6_sub;
  logic [63:0] v, r0, r1, r2;
  leaf6 i0(.v(v), .r(r0));
  leaf6 i1(.v(v), .r(r1));
  leaf6 i2(.v(v), .r(r2));
endmodule

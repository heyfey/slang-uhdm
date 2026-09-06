// r10v105 v2 — THREE INSTANCES of one leaf, each overriding the same `int`
// parameter in a DIFFERENT spelling, read BARE (the NEW window) and in a
// SELECT position (an OLD window) from the leaf's top-level gen-for body.
// Per-instance substitution: each instance must carry ITS OWN override's
// encoding, and the two windows must not disagree with each other.
module v2_leaf105 #(
  parameter int P = 2,
  parameter int Q = 3
) (input logic [31:0] sig, output logic [63:0] z);
  for (genvar i = 0; i < 2; i++) begin : gen_i
    logic [63:0] r0,r1,r2,r3;
    assign r0 = P ^ sig;          // NEW window, plain
    assign r1 = sig[P];           // OLD window, bit-select index
    assign r2 = {P, Q} ^ sig;     // NEW window, concat operands
    assign r3 = sig[P +: 2];      // OLD window, ips base
  end
  assign z = 64'b0;
endmodule

module v2_inst105 (input logic [31:0] sig, output logic [63:0] z);
  logic [63:0] za, zb, zc;
  v2_leaf105 #(.P(2),       .Q(3))       u_dec (.sig(sig), .z(za));
  v2_leaf105 #(.P(4'b0010), .Q(4'h3))    u_bin (.sig(sig), .z(zb));
  v2_leaf105 #(.P(1+1),     .Q(6'o03))   u_exp (.sig(sig), .z(zc));
  assign z = za ^ zb ^ zc;
endmodule

// r10rgg15 grid g2 — the SAME targets, each OVERRIDDEN by an unsized fill, by
// a sized literal, and by a parameter, from THREE instances.  The DEFAULT is
// deliberately a DIFFERENT spelling from the override so the two can never be
// confused in the census.  MEASUREMENT ONLY.
module g2_sub #(
  parameter bit   [7:0] B_b8   = 8'hab,
  parameter logic [7:0] B_l8   = 8'hab,
  parameter bit   [1:0] B_b2   = 2'h3,
  parameter bit         B_b1   = 1'b1,
  parameter int         B_int  = 7,
  parameter             B_unt  = 7,
  parameter      [7:0]  B_ru8  = 8'hab,
  parameter bit  [64:0] B_b65  = 65'h1
)();
endmodule

module g2_top;
  // every formal overridden by the unsized fill '0
  g2_sub #(.B_b8('0), .B_l8('0), .B_b2('0), .B_b1('0), .B_int('0),
           .B_unt('0), .B_ru8('0), .B_b65('0)) u_zero ();
  // every formal overridden by the unsized fill '1
  g2_sub #(.B_b8('1), .B_l8('1), .B_b2('1), .B_b1('1), .B_int('1),
           .B_unt('1), .B_ru8('1), .B_b65('1)) u_ones ();
  // sized-literal controls
  g2_sub #(.B_b8(8'h00), .B_l8(8'h00), .B_b2(2'h0), .B_b1(1'b0),
           .B_int(0), .B_unt(0), .B_ru8(8'h00), .B_b65(65'h0)) u_sized ();
endmodule

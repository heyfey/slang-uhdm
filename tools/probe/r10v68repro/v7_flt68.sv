// r10v68 arm v7 — one floating declaration per module, order swapped, to
// isolate WHICH floating kind golden sizes at 32.  MEASUREMENT ONLY.
module v7_a68 (output logic [7:0] o);            // real ONLY
  real x;
  for (genvar i = 3; i < 4; i++) begin : g assign x = i; end
  assign o = {7'b0, (x > 0.0)};
endmodule
module v7_b68 (output logic [7:0] o);            // shortreal ONLY
  shortreal x;
  for (genvar i = 3; i < 4; i++) begin : g assign x = i; end
  assign o = {7'b0, (x > 0.0)};
endmodule
module v7_c68 (output logic [7:0] o);            // realtime ONLY
  realtime x;
  for (genvar i = 3; i < 4; i++) begin : g assign x = i; end
  assign o = {7'b0, (x > 0.0)};
endmodule
module v7_d68 (output logic [7:0] o);            // shortreal declared FIRST
  shortreal x;
  real y;
  for (genvar i = 3; i < 4; i++) begin : g assign x = i; assign y = i; end
  assign o = {7'b0, (x > 0.0)} ^ {7'b0, (y > 0.0)};
endmodule
module v7_flt68 (output logic [7:0] o);
  logic [7:0] a, b, c, d;
  v7_a68 ua (.o(a)); v7_b68 ub (.o(b)); v7_c68 uc (.o(c)); v7_d68 ud (.o(d));
  assign o = a ^ b ^ c ^ d;
endmodule

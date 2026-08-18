// r10v68 arm v6 — the FLOATING Lhs at DISTANCE 0 (where the PRISTINE emitter
// already folded to sz 64) vs golden.  MEASUREMENT ONLY.
module v6_real68 (input logic [7:0] din, output logic [7:0] dout);
  real      r0, r1;
  shortreal s0, s1;
  realtime  t0;
  logic [7:0] v0;
  // distance 0 — the PRE-EXISTING fold arm.
  for (genvar i = 3; i < 4; i++) begin : g_d0
    assign r0 = i;                 // real,      distance 0
    assign s0 = i;                 // shortreal, distance 0
    assign t0 = i;                 // realtime,  distance 0
    assign v0 = i;                 // logic[7:0],distance 0
  end
  // distance 1 — the NEW arm.
  for (genvar i = 5; i < 6; i++) begin : g_d1
    if (i > 0) begin : b1
      assign r1 = i;               // real,      distance 1
      assign s1 = i;               // shortreal, distance 1
    end
  end
  assign dout = v0 ^ din ^ {7'b0, (r0 > 0.0)} ^ {7'b0, (s0 > 0.0)} ^
                {7'b0, (t0 > 0.0)} ^ {7'b0, (r1 > 0.0)} ^ {7'b0, (s1 > 0.0)};
endmodule

// r10v105 v6 — a PORT ACTUAL and a nested instantiation inside the loop body:
// the high_conn laws' territory (r10earl57 R-A).  A parameter read as an
// instance's port connection or as a parameter override inside a top-level
// loop-generate body of a child instance must not move.
module v6_sub105 (input logic [31:0] a, output logic [31:0] y);
  assign y = a;
endmodule

module v6_leaf105 #(parameter int P = 6) (input logic [31:0] sig, output logic [63:0] z);
  localparam int MOD = 9;
  for (genvar i = 0; i < 2; i++) begin : gen_p
    logic [31:0] t0, t1;
    v6_sub105 u_s (.a(sig ^ MOD), .y(t0));      // a param inside a PORT ACTUAL
    v6_sub105 u_t (.a({MOD}),     .y(t1));      // a param as the WHOLE actual
    logic [63:0] e0;
    assign e0 = t0 ^ t1 ^ MOD;                  // the law's own window beside it
  end
  assign z = 64'b0;
endmodule

module v6_port105 (input logic [31:0] sig, output logic [63:0] z);
  logic [63:0] zc;
  v6_leaf105 #(.P(6)) u_leaf (.sig(sig), .z(zc));
  assign z = zc;
endmodule

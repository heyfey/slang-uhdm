// r10earl65 GRID ARM 2 — the DOTTED (hier_path) form of the same cells: the
// ELAB port High_conn actual is `st_i.f[0 +: PW]`, which the emitter builds
// through the hier_path arm (§ elabHierSelWidthFold), not the plain ips arm.
// MEASUREMENT ONLY.
package q65;
  localparam int QW = 5;
  localparam int QB = 2;
endpackage

typedef struct packed {
  logic [63:0] f;
} st65_t;

module leaf65b (input logic [31:0] a_i, input logic b_i, output logic o_o);
  assign o_o = ^a_i ^ b_i;
endmodule

module g2_hier65 import q65::*; (
  input  st65_t st_i,
  output logic [3:0] o_o
);
  localparam int LQ = 5;
  // dotted ips WIDTH / BASE, package parameter
  leaf65b u_h_w (.a_i(st_i.f[0  +: QW]), .b_i(st_i.f[0]), .o_o(o_o[0]));
  leaf65b u_h_b (.a_i(st_i.f[QB +: 32]), .b_i(st_i.f[0]), .o_o(o_o[1]));
  // dotted part-select bounds (negative control)
  leaf65b u_h_ps(.a_i({27'b0, st_i.f[QW-1:QB]}), .b_i(st_i.f[0]), .o_o(o_o[2]));
  // dotted ips width, MODULE-BODY localparam
  leaf65b u_h_l (.a_i(st_i.f[0  +: LQ]), .b_i(st_i.f[0]), .o_o(o_o[3]));
endmodule

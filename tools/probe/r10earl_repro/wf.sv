// wf.sv — PASS 15: the dm_pkg head (2 of them, dm_mem + rv_dm).
//   dm_pkg.sv:29  `localparam logic [63:0] ResumeAddress = HaltAddress + 4;`
//   golden  constant :29:43 {ct=9 sz=64 dec=2052}      ours  operation :29:43
// A PACKAGE localparam whose init reads a SAME-PACKAGE localparam, seen in the
// materialized import copy inside a module's DEF listing.  Rows vary the
// declared type and the operator so the fold/encoding questions separate.
package wfp;
  localparam logic [63:0] H  = 64'h800;
  // H1 — the head shape: same-package localparam operand, `logic [W:0]` type.
  localparam logic [63:0] R1 = H + 4;
  // H2 — the `int` twin (does the already-landed arithmetic fold cover it?).
  localparam int HI = 5;
  localparam int R2 = HI + 4;
  // H3 — declared with `parameter`, not `localparam`.
  parameter logic [63:0] HP = 64'h900;
  parameter logic [63:0] R3 = HP + 4;
  // H4 — the SUBTRACT form (paramIntEnc's `X-1` shape): INT or UINT?
  localparam logic [63:0] R4 = H - 1;
  // H5 — a same-package operand under `/` (paramIntEnc arithmetic).
  localparam logic [63:0] R5 = H / 2;
  // H6 — no package-param operand at all (pure literal arithmetic control).
  localparam logic [63:0] R6 = 64'h10 + 4;
endpackage

module wfnp import wfp::*; (
  input  logic        req_i,
  output logic [63:0] o_o
);
  assign o_o = R1 ^ {64{req_i}};
endmodule

module wftop;
  logic r;
  logic [63:0] o;
  wfnp u0(.req_i(r), .o_o(o));
endmodule

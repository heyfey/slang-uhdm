// v2 (VERIFIER) — the operand kinds `srlgClassify49` calls RefConst-and-continue
// or Skip, in a position where a LATER parameter's answer reports whether the
// walk really continued past them.  A concat's operands are walked in source
// order, so operand0 is the probe and operand1 is the reporter.
typedef enum logic [31:0] { EV_A = 32'h7, EV_B = 32'h9 } v2e_t;

module v2_v49 #(
  parameter int           W  = 32,
  parameter logic [W-1:0] G1 = 32'h1,  // {EV_A , G1 , n} — ENUM VALUE probe
  parameter logic [W-1:0] G2 = 32'h2,  // {$clog2(W), G2, n} — SYS-CALL probe
  parameter logic [W-1:0] G3 = 32'h3,  // {32'h5, G3, n} — CONSTANT probe
  parameter logic [W-1:0] G4 = 32'h4,  // {G4, n} — control, must be BARE
  parameter logic [W-1:0] G5 = 32'h5,  // {n, G5} — control, must be LOCATED
  parameter logic [W-1:0] G6 = 32'h6,  // {{(W){1'b0}}, G6, n} — REPLICATION probe
  parameter logic [W-1:0] G7 = 32'h7   // {(G7){1'b0}} as a replication COUNT
) (
  input  logic [W-1:0] n,
  output logic [95:0]  q1, q2, q3, q6,
  output logic [63:0]  q4, q5,
  output logic [W-1:0] q7
);
  assign q1 = {EV_A, G1, n};
  assign q2 = {$clog2(W), G2, n};
  assign q3 = {32'h5, G3, n};
  assign q4 = {G4, n};
  assign q5 = {n, G5};
  assign q6 = {{(W){1'b0}}, G6, n};
  assign q7 = {{(W-1){1'b0}}, |{(G7){1'b1}}} | n;
endmodule

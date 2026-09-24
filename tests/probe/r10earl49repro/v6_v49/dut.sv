// v6 (VERIFIER) — decides whether a PACKAGE-parameter operand is Skip (stepped
// over, walk continues) or Stop, and whether the scope-blind harvest survives
// when the colliding name is ALSO legitimately read.  A concat walks its
// operands in source order, so operand0 is the probe and operand1 reports.
package v6p;
  parameter logic [31:0] KA = 32'h11;  // collides with the module's KA
  parameter logic [31:0] KP = 32'h22;  // probe at operand0
  parameter logic [31:0] KQ = 32'h33;  // probe at operand0, own-read control
endpackage

module v6_v49 #(
  parameter int           W  = 32,
  parameter logic [W-1:0] KA = 32'h44, // NEVER read locally; pkg twin IS read
  parameter logic [W-1:0] KR = 32'h55, // reporter after a PACKAGE-param operand
  parameter logic [W-1:0] KS = 32'h66, // reporter after a NET operand (control)
  parameter logic [W-1:0] KT = 32'h77  // read locally AND has no pkg twin
) (
  input  logic [W-1:0] n,
  output logic [W-1:0] o1,
  output logic [95:0]  q2, q3,
  output logic [W-1:0] o4
);
  assign o1 = v6p::KA | n;      // package KA at operand0; module KA untouched
  assign q2 = {v6p::KP, KR, n}; // does the walk continue PAST a package param?
  assign q3 = {n, KS};          // control: a net operand stops it
  assign o4 = KT | n;           // control: a genuine local read must stay BARE
endmodule

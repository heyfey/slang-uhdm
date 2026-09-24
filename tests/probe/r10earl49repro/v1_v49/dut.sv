// v1 (VERIFIER) — SCOPE-BLIND NAME HARVEST.
// `srlgCaOperandScan49` inserts `sym.name` for every Parameter operand it walks,
// and `paramCaFoldRead` answers `names.count(ps.name)`.  Neither is scoped.  So a
// PACKAGE parameter read at operand0 of a cont-assign should mark a MODULE
// parameter of the SAME NAME as read, even though nothing in the module reads it.
// Pristine cannot reach this cell at all (the RHS is not a ternary), so golden
// LOCATED here would be a pristine-right -> patched-wrong regression.
package v1p;
  parameter int          W  = 32;
  parameter logic [31:0] KA = 32'h11;   // read at operand0 of a cont-assign
  parameter logic [31:0] KZ = 32'h99;   // never read
endpackage

module v1_v49 #(
  parameter int           W  = 32,
  parameter logic [W-1:0] KA = 32'h33,  // module's own KA: NEVER read anywhere
  parameter logic [W-1:0] KZ = 32'h44,  // module's own KZ: never read either
  parameter logic [W-1:0] KC = 32'h55   // CONTROL: read at operand0 -> BARE
) (
  input  logic [W-1:0] n,
  output logic [W-1:0] o1, o2
);
  assign o1 = v1p::KA | n;   // package KA at operand0; module KA is untouched
  assign o2 = KC | n;        // control cell
endmodule

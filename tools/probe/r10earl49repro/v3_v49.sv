// v3 (VERIFIER) — the RANGE-SHAPE axes the brief named and the pass did not
// measure: SIGNED bounds, a SIGNED parameter, a $clog2 bound, a package-parameter
// bound, a typedef'd dimension, an untyped ranged parameter and an untyped
// sized-literal parameter.  Every cell is read in the SAME position (operand0 of
// `P | n`), so any per-cell disagreement is a RANGE-SHAPE effect, not a position
// effect.
package v3p;
  parameter int PW = 16;
endpackage

typedef logic [11:0] v3_t;

module v3_v49 #(
  parameter int signed              SW = 32,
  parameter logic [SW-1:0]          S1 = 'h1,  // signed-int bound expression
  parameter logic signed [31:0]     S2 = 'h2,  // SIGNED parameter
  parameter logic [$clog2(1024)-1:0] S3 = 'h3, // $clog2 bound
  parameter logic [v3p::PW-1:0]     S4 = 'h4,  // package-parameter bound
  parameter v3_t                    S5 = 'h5,  // typedef'd dimension
  parameter logic [SW-1:0]          S6 = 'h6,  // CONTROL: never read
  parameter [7:0]                   S7 = 'h7,  // untyped RANGED
  parameter                         S8 = 8'h8, // untyped SIZED LITERAL
  parameter logic [3:0][7:0]        S9 = 'h9   // MULTI-DIM packed
) (
  input  logic [31:0] n,
  output logic [31:0] o1, o2, o3, o4, o5, o7, o8, o9
);
  assign o1 = S1 | n;
  assign o2 = S2 | n;
  assign o3 = S3 | n;
  assign o4 = S4 | n;
  assign o5 = S5 | n;
  assign o7 = S7 | n;
  assign o8 = S8 | n;
  assign o9 = S9 | n;
endmodule

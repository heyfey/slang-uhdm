// r10earl92 grid 2 — CONDITION SHAPES on the head's context (plain ref_obj
// Lhs, non-value-able xor arm).  Every cell asks the same question: does the
// ELABORATED cont_assign install the selected arm?
package g2pkg;
  parameter bit PKG_EN = 1;
  parameter bit PKG_OFF = 0;
endpackage

module g2leaf #(parameter bit EN = 1, parameter bit OFF = 0,
                parameter int P1 = 2, parameter int P2 = 3) (
  input  logic [7:0][31:0] k,
  input  logic [31:0]      sig,
  output logic [31:0]      o
);
  import g2pkg::*;
  localparam bit LP_EN  = 1;
  localparam bit LP_OFF = 0;
  // d_bareparam_1 / d_bareparam_0 — a bare parameter, true and false
  logic [31:0] d_bareparam_1; assign d_bareparam_1 = EN  ? k[5] ^ k[1] : k[2] ^ k[3];
  logic [31:0] d_bareparam_0; assign d_bareparam_0 = OFF ? k[5] ^ k[1] : k[2] ^ k[3];
  // d_localparam_1 / d_localparam_0
  logic [31:0] d_localparam_1; assign d_localparam_1 = LP_EN  ? k[5] ^ k[1] : k[2] ^ k[3];
  logic [31:0] d_localparam_0; assign d_localparam_0 = LP_OFF ? k[5] ^ k[1] : k[2] ^ k[3];
  // d_paramexpr — an EXPRESSION of parameters
  logic [31:0] d_paramexpr; assign d_paramexpr = ((P1 + P2) > 4) ? k[5] ^ k[1] : k[2] ^ k[3];
  // d_pkgparam — a PACKAGE parameter (bare, and scope-qualified)
  logic [31:0] d_pkgparam;  assign d_pkgparam  = PKG_EN ? k[5] ^ k[1] : k[2] ^ k[3];
  logic [31:0] d_pkgqual;   assign d_pkgqual   = g2pkg::PKG_OFF ? k[5] ^ k[1] : k[2] ^ k[3];
  // d_signal — a NON-CONSTANT signal condition
  logic [31:0] d_signal;    assign d_signal    = sig[0] ? k[5] ^ k[1] : k[2] ^ k[3];
  // d_condop — a comparison of a parameter against a literal
  logic [31:0] d_condop;    assign d_condop    = (P1 == 2) ? k[5] ^ k[1] : k[2] ^ k[3];
  // d_condcall — a $-call condition ExprEval CAN evaluate
  logic [31:0] d_condcall;  assign d_condcall  = ($clog2(P1 + 6) > 2) ? k[5] ^ k[1] : k[2] ^ k[3];
  assign o = d_bareparam_1 ^ d_bareparam_0 ^ d_localparam_1 ^ d_localparam_0 ^
             d_paramexpr ^ d_pkgparam ^ d_pkgqual ^ d_signal ^ d_condop ^ d_condcall;
  // d_genvar — a GENVAR condition, inside a gen-for
  for (genvar gi = 0; gi < 2; gi++) begin : gblk
    logic [31:0] d_genvar;
    assign d_genvar = (gi == 0) ? k[5] ^ k[1] : k[2] ^ k[3];
  end
endmodule

module g2top (input logic [7:0][31:0] k, input logic [31:0] sig,
              output logic [31:0] a, b);
  // two instances, one DEFAULT and one OVERRIDDEN, so the per-instance split
  // is visible (r10rgg9's p_ov10 / p_ov01 rule).
  g2leaf #(.EN(1), .OFF(0))            u_def (.k(k), .sig(sig), .o(a));
  g2leaf #(.EN(0), .OFF(1), .P1(0))    u_ov  (.k(k), .sig(sig), .o(b));
endmodule

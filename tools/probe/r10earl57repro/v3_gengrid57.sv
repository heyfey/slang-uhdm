// r10earl57 v3 — INSIDE THE GENERATE BLOCK, the full cast-target grid.
// v2 established that a GEN-BLOCK cont-assign cast takes the FRESH NAMED
// int_typespec where the same target at module scope keeps its DECLARATION
// typespec.  This arm asks how far that reaches: which POSITIONS inside the
// block, and which TARGET SPELLINGS.
package p57;
  parameter int unsigned PKW  = 9;
  localparam int unsigned PKL = 10;
endpackage

import p57::*;
module g57 #(
  parameter  int unsigned PLIT  = 8,
  parameter  int unsigned PDEP  = PLIT + 1,
  localparam int unsigned QDEP  = (PLIT == 0) ? 1 : PLIT,
  parameter  integer      PINTG = PLIT + 2,
  parameter               PUNT  = PLIT + 3,
  parameter  logic [7:0]  PLOG  = PLIT + 4
) (
  input  logic [31:0] sig,
  output logic [31:0] ca1, ca2, ca3, ca4, ca5,
  output logic [31:0] pr1, pr2, ini1,
  output logic [31:0] gl1, gl2, pk1, pk2, gv1,
  output logic [31:0] ex1, sg1, ty1, nc1
);
  localparam int unsigned BDEP = $clog2(PLIT + 1);
  typedef logic [7:0] t57_t;

  if (PLIT > 1) begin : gen_g57
    // gen-scope-declared localparams
    localparam int unsigned GLIT = 4;
    localparam int unsigned GDEP = BDEP + 1;

    // --- CONT-ASSIGN positions (the v2 rows, re-measured here) ------
    assign ca1 = PDEP'(sig);
    assign ca2 = QDEP'(sig);
    assign ca3 = BDEP'(sig);
    assign ca4 = PINTG'(sig);
    assign ca5 = PLOG'(sig);

    // --- PROCEDURAL inside the block --------------------------------
    always_comb pr1 = QDEP'(sig);
    always_comb pr2 = BDEP'(sig);
    logic [31:0] iv;
    initial iv = QDEP'(sig);
    assign ini1 = iv;

    // --- GEN-SCOPE-DECLARED target ----------------------------------
    assign gl1 = GLIT'(sig);
    assign gl2 = GDEP'(sig);

    // --- PACKAGE parameter target -----------------------------------
    assign pk1 = p57::PKW'(sig);
    assign pk2 = PKL'(sig);

    // --- EXPRESSION / SIGN / TYPE / NESTED --------------------------
    assign ex1 = (QDEP+1)'(sig);
    assign sg1 = signed'(sig);
    assign ty1 = t57_t'(sig);
    assign nc1 = QDEP'(BDEP'(sig));
  end else begin : gen_e57
    assign ca1='0; assign ca2='0; assign ca3='0; assign ca4='0; assign ca5='0;
    assign pr1='0; assign pr2='0; assign ini1='0; assign gl1='0; assign gl2='0;
    assign pk1='0; assign pk2='0; assign ex1='0; assign sg1='0; assign ty1='0;
    assign nc1='0;
  end

  for (genvar gi = 1; gi < 2; gi++) begin : gen_l57
    assign gv1 = gi'(sig);
  end
endmodule

module top57g (
  input  logic [31:0] s,
  output logic [31:0] q1, q2, q3, q4, q5, q6, q7, q8, q9, q10,
  output logic [31:0] q11, q12, q13, q14, q15, q16
);
  import p57::*;
  g57 i_g (.sig(s), .ca1(q1), .ca2(q2), .ca3(q3), .ca4(q4), .ca5(q5),
           .pr1(q6), .pr2(q7), .ini1(q8), .gl1(q9), .gl2(q10),
           .pk1(q11), .pk2(q12), .gv1(q13), .ex1(q14), .sg1(q15), .ty1(q16),
           .nc1());
endmodule

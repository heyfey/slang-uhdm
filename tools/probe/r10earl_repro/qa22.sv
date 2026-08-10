// qa22.sv — PASS 22.  THE MISSING QUARTER of pass 21's refuted
// § genCaEnumConstNoBind21 2x2.  qh21.sv measured: inside a gen-scope
// cont_assign RHS, a wildcard-imported PACKAGE enum const read as a TERNARY
// BRANCH VALUE stays UNBOUND in golden (if-gen, for-gen and top-module-gen
// rows alike) where we bind — that is the top_earlgrey head at
// ibex_id_stage.sv:911:45.  But the naive widening REGRESSED two u2r tests
// where golden BINDS the very same kind of ref in the very same kind of
// scope:
//   hier_path                    (csr_pmp_cfg_i[r].mode == PMP_MODE_TOR) ? ..
//                                a PACKAGE enum as a COMPARISON OPERAND, and
//                                that comparison is the ternary's CONDITION
//   MultirangesStartNotFromZero  io_fwd_mesh_li[i][e_e:w_e]
//                                a MODULE enum as a PART-SELECT BOUND
// This file writes all three shapes into ONE design so the discriminator is
// directly visible, and adds the rows that separate the candidate features:
//   * BRANCH vs CONDITION of the same ternary (R1 vs R2 — one statement)
//   * comparison operand with NO ternary above it (R3)
//   * part-select bound, package enum (R4) and module enum (R5)
//   * bit-select INDEX (R6)
//   * bare whole-RHS enum read in a gen scope (R7)
//   * enum under a plain bitwise operation, no ternary (R8)
//   * ternary branch where the enum sits one operation DEEPER (R9)
// Module-level controls for the same shapes are M1..M3 (qh21 R5 showed the
// module-level ternary branch BINDS in both views).
package qa22_pkg;
  typedef enum logic [1:0] {
    E_A = 2'd0,
    E_B = 2'd1,
    E_C = 2'd2
  } e_t;
endpackage

module qa22_child
  import qa22_pkg::*;
(
    input  logic       c,
    input  e_t         s,
    input  logic [7:0] w,
    output e_t         r1,
    output logic       r2,
    output logic       r3,
    output logic [1:0] r4,
    output logic [1:0] r5,
    output logic       r6,
    output e_t         r7,
    output logic [1:0] r8,
    output e_t         r9,
    output e_t         m1,
    output logic       m2,
    output logic [1:0] m3
);
  typedef enum logic [2:0] { L_P = 3'd0, L_W, L_E, L_N } l_t;

  // ---- module-level controls (qh21 R5 says the branch row BINDS here) ----
  assign m1 = c ? E_A : E_B;                 // M1 branch, module level
  assign m2 = (s == E_A) ? 1'b1 : 1'b0;      // M2 comparison operand
  assign m3 = w[L_E:L_W];                    // M3 part-select bound

  // ---- gen scope: branch vs condition in ONE statement ----------------
  if (1) begin : gen_if
    assign r1 = (s == E_C) ? E_A : E_B;      // R1 BRANCHES  / R2 CONDITION
    assign r2 = (s == E_B);                  // R3 comparison, no ternary
    assign r4 = w[E_C:E_A];                  // R4 part-select bound, PKG enum
    assign r5 = w[L_E:L_W];                  // R5 part-select bound, MOD enum
    assign r6 = w[E_B];                      // R6 bit-select index
    assign r7 = E_A;                         // R7 bare whole-RHS read
    assign r8 = E_A | E_B;                   // R8 plain bitwise operands
    assign r9 = c ? (E_A | E_B) : E_C;       // R9 branch one op deeper
  end

  for (genvar g = 0; g < 1; g++) begin : gen_for
    assign r3 = (s == E_C) ? 1'b1 : 1'b0;    // for-gen twin of R3/condition
  end
endmodule

module qa22
  import qa22_pkg::*;
(
    input  logic       c,
    input  e_t         s,
    input  logic [7:0] w,
    output e_t         r1,
    output logic       r2,
    output logic       r3,
    output logic [1:0] r4,
    output logic [1:0] r5,
    output logic       r6,
    output e_t         r7,
    output logic [1:0] r8,
    output e_t         r9,
    output e_t         m1,
    output logic       m2,
    output logic [1:0] m3
);
  qa22_child u_c (.c(c), .s(s), .w(w), .r1(r1), .r2(r2), .r3(r3), .r4(r4),
                  .r5(r5), .r6(r6), .r7(r7), .r8(r8), .r9(r9),
                  .m1(m1), .m2(m2), .m3(m3));
endmodule

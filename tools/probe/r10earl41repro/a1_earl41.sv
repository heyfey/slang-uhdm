// r10earl41 GRID — three axes in one arm:
//
//   A. THE WHITESPACE AXIS (F3).  r10earl40's ScopedName delegation mints the
//      qualified base with `raw.substr(0, raw.find('['))`, so ANY whitespace
//      written before the first selector lands INSIDE vpiName
//      (`q41::A [g]` -> "q41::A ") and propagates into every child fullname.
//      Zero occurrences in Earlgrey, so only an arm can prove it.
//
//   B. THE ELABORATED TWIN (earl40 residue R1).  A package-scoped base with
//      TWO OR MORE selectors read through the AST path (emitExpr) names its
//      var_select / part_select with the BARE tail.  The discriminator is
//      measured here, not assumed: symbol's HOME PACKAGE vs the WRITTEN
//      spelling (an imported name written bare is the separating cell).
//
//   C. THE BOUNDARY CONTROLS.  A local base, a single-selector package select
//      and the `+:`/`-:` abstain must all stay exactly where earl40 left them.
//
// Every measured net is named c_<cell> so cells41.py can read it VIEW-KEYED
// (def = uhdmallModules, elab = uhdmtopModules — the section, not a `[i]`
// heuristic, because module-level cells appear in both views with the SAME
// fullname).
package p41;
  parameter int DW = 8;
  parameter logic [3:0][7:0] A = {8'h1, 8'h2, 8'h3, 8'h4};
  parameter logic [3:0][7:0] B = {8'h5, 8'h6, 8'h7, 8'h8};
  parameter logic [63:0]     C = 64'h0123456789abcdef;
  parameter logic [1:0][3:0][7:0] D = {32'h01020304, 32'h05060708};
endpackage

package q41;
  parameter logic [3:0][7:0] A = {8'h9, 8'ha, 8'hb, 8'hc};
endpackage

module a1_earl41 #(parameter int DW = 8) (input logic [1:0] sel, output logic [7:0] o);
  import q41::*;
  logic [3:0][7:0] loc;
  assign loc = p41::A;

  // ======== B. THE ELABORATED TWIN — module level (BOTH views) ========
  // b1: cont_assign, QUALIFIED base, variable index.
  logic [7:0] c_mca_pkg_bk;
  assign c_mca_pkg_bk = p41::A[sel][DW-1:0];

  // b2: always_comb, QUALIFIED base, variable index.
  logic [7:0] c_mpr_pkg_bk;
  always_comb c_mpr_pkg_bk = p41::A[sel][DW-1:0];

  // b3: always_comb, QUALIFIED base, LITERAL index — prim_prince 81:22.
  logic [7:0] c_mpr_pkg_blit;
  always_comb c_mpr_pkg_blit = p41::A[1][DW-1:0];

  // b4: THE SEPARATING CELL — imported package name written BARE.  If golden
  // qualifies this one the law is "the symbol's home package"; if it leaves it
  // bare the law is "the WRITTEN spelling".
  logic [7:0] c_mpr_imp_blit;
  always_comb c_mpr_imp_blit = A[1][DW-1:0];

  // b5: its twin — same imported package, written QUALIFIED.
  logic [7:0] c_mpr_impq_blit;
  always_comb c_mpr_impq_blit = q41::A[1][DW-1:0];

  // b6: LOCAL base control — must never gain a qualifier.
  logic [7:0] c_mpr_loc_blit;
  always_comb c_mpr_loc_blit = loc[1][DW-1:0];

  // b7: SINGLE selector, package base, bit select — boundary control.
  logic [7:0] c_mpr_pkg_one;
  always_comb c_mpr_pkg_one = p41::B[0];

  // b8: SINGLE selector, package base, RANGE select — prim_prince 59:55.
  logic [7:0] c_mpr_pkg_rng;
  always_comb c_mpr_pkg_rng = p41::C[DW-1:0];

  // b9b: package base, TWO ELEMENT selectors and NO trailing range — the
  // shape that reaches the OTHER elab var_select builder (nested element
  // select).  Its corpus footprint is predicted ZERO; this cell is what makes
  // the prediction falsifiable.
  logic c_mpr_pkg_bb;
  always_comb c_mpr_pkg_bb = p41::A[sel][0];

  // b9: package base, THREE selectors.
  logic [7:0] c_mpr_pkg_three;
  always_comb c_mpr_pkg_three = p41::D[sel[0]][1][DW-1:0];

  for (genvar g = 0; g < 2; g++) begin : gb
    // ======== A. THE WHITESPACE AXIS (def-view syntax path) ========
    // a0: the CONTROL — no whitespace anywhere (earl40's shipped shape).
    logic [7:0] c_ws_none;
    assign c_ws_none = q41::A[g][DW-1:0];

    // a1: whitespace BEFORE the first selector — the F3 defect itself.
    logic [7:0] c_ws_trail;
    assign c_ws_trail = q41::A [g][DW-1:0];

    // a2: whitespace BETWEEN the two selectors.
    logic [7:0] c_ws_mid;
    assign c_ws_mid = q41::A[g] [DW-1:0];

    // a3: whitespace BEFORE the `::`.
    logic [7:0] c_ws_coll;
    assign c_ws_coll = q41 ::A[g][DW-1:0];

    // a4: whitespace AFTER the `::`.
    logic [7:0] c_ws_colr;
    assign c_ws_colr = q41:: A[g][DW-1:0];

    // a5: whitespace EVERYWHERE.
    logic [7:0] c_ws_all;
    assign c_ws_all = q41 :: A [g] [DW-1:0];

    // ======== C. BOUNDARY CONTROLS inside the same generate ========
    // c1: earl40's own head shape, untouched.
    logic [7:0] c_gca_pkg_bk;
    assign c_gca_pkg_bk = q41::A[g][DW-1:0];

    // c2: the `-:` ABSTAIN (earl40 residue R3 + this pass's F4 orphan probe).
    logic [3:0] c_gca_pkg_bidx;
    assign c_gca_pkg_bidx = q41::A[g][DW-1 -: 4];

    // c3: LOCAL base inside the same generate — must stay byte-identical.
    logic [7:0] c_gca_loc_bk;
    assign c_gca_loc_bk = loc[g][DW-1:0];
  end

  assign o = c_mca_pkg_bk ^ c_mpr_pkg_bk ^ c_mpr_pkg_blit ^ c_mpr_imp_blit ^
             c_mpr_impq_blit ^ c_mpr_loc_blit ^ c_mpr_pkg_one ^
             c_mpr_pkg_rng ^ c_mpr_pkg_three ^ {7'b0, c_mpr_pkg_bb} ^
             gb[0].c_ws_none ^ gb[0].c_ws_trail ^ gb[0].c_ws_mid ^
             gb[0].c_ws_coll ^ gb[0].c_ws_colr ^ gb[0].c_ws_all ^
             gb[0].c_gca_pkg_bk ^ {4'b0, gb[0].c_gca_pkg_bidx} ^
             gb[0].c_gca_loc_bk;
endmodule

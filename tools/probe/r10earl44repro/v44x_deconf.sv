// r10earl44 VERIFIER probe — DE-CONFOUNDING the two arms of
// § scopedConnPkgParamSubst44.
//
// THE PROBLEM WITH a1_earl44.sv AND v44_overfire.sv: in BOTH files every cell
// that lands in ARM 1 (the bare-constant fold) is a SCALAR parameter, and
// every cell that lands in ARM 2 (the surviving qualified ref_obj) is an
// AGGREGATE (packed struct / unpacked array).  The stated law says the split
// is on CONSTNESS ("is there a value to hand over" — `pkgParamConst` vs
// `paramDefRhsIsOp`), but the grid is equally consistent with a split on
// SHAPE (scalar folds, aggregate stays symbolic).  The two hypotheses are
// experimentally indistinguishable in the delivered probes.
//
// THE TWO CELLS THAT SEPARATE THEM — each breaks the correlation one way:
//
//   x1/x2  SCALAR with an OPERATION Rhs (concat / replication).  Not in
//          pkgParamConst, IS paramDefRhsIsOp  ->  LAW predicts ARM 2, a
//          surviving QUALIFIED ref_obj on a SCALAR.  SHAPE theory predicts a
//          folded bare constant.
//   x3     AGGREGATE (packed struct) with a CONSTANT Rhs.  IS in
//          pkgParamConst  ->  LAW predicts ARM 1, a BARE CONSTANT fold of an
//          AGGREGATE.  SHAPE theory predicts a surviving ref_obj.
//
// PLUS the empty product cells the delivered grid never fills:
//   x4     ARM 2 x a formal that FORCES AN IMPLICIT CONVERSION.  The § 44 gate
//          reads the RAW `expr` (`expr->kind == NamedValue`), while § 43's
//          gate reads `stripImplicitConv(*expr)`.  Every aggregate cell in
//          a1_earl44 is wired to an EXACTLY-matching formal, so a conversion
//          never wraps an arm-2 actual there and the asymmetry is untested.
//   x5     ARM 2 x POSITIONAL connection.  a1_earl44's only positional cell
//          (u_q16) is a SCALAR and its row is "no def-view port either side",
//          i.e. it measured NOTHING.
//   x6     ARM 2 x a param whose Rhs is a CONCATENATION rather than an
//          assignment pattern (every arm-2 cell in the delivered probes is an
//          assignment pattern).

package x44;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } sx_t;

  // ---- SCALAR params whose def Rhs is an OPERATION ------------------------
  localparam logic [15:0] PK_CAT = {8'h aa, 8'h bb};      // concatenation
  localparam logic [15:0] PK_REP = {2{8'h cd}};           // replication

  // ---- AGGREGATE param whose def Rhs is a CONSTANT ------------------------
  localparam sx_t         PK_STC = 16'h aabb;             // struct from literal

  // ---- the delivered probes' shapes, carried for a same-file control ------
  localparam sx_t         PK_STP = '{a: 8'h 11, b: 8'h 22}; // struct, pattern
  localparam logic [15:0] PK_PLN = 16'h 8000;               // scalar, constant

  // ---- AGGREGATE whose Rhs is a CONCAT (not a pattern) --------------------
  localparam sx_t         PK_SCAT = {8'h 33, 8'h 44};
endpackage

module lf16   (input logic [15:0] p_i);
endmodule
module lfst   (input x44::sx_t p_i);
endmodule
module lf32   (input logic [31:0] p_i);   // WIDER formal -> implicit conversion
endmodule

module topx44;
  import x44::*;

  // ===== THE DE-CONFOUNDING PAIR =========================================
  lf16 u_x1 (.p_i (x44::PK_CAT));    // SCALAR  + op Rhs   -> arm 2 per the LAW
  lf16 u_x2 (.p_i (x44::PK_REP));    // SCALAR  + op Rhs   -> arm 2 per the LAW
  lfst u_x3 (.p_i (x44::PK_STC));    // AGGREG. + const Rhs-> arm 1 per the LAW

  // ===== same-file controls, the delivered probes' own shapes =============
  lfst u_x7 (.p_i (x44::PK_STP));    // AGGREG. + op Rhs   -> arm 2 (u_q7's twin)
  lf16 u_x8 (.p_i (x44::PK_PLN));    // SCALAR  + const Rhs-> arm 1 (u_q1's twin)

  // ===== EMPTY PRODUCT CELLS =============================================
  lf32 u_x4 (.p_i (x44::PK_STP));    // arm 2 x IMPLICIT CONVERSION (16->32)
  lfst u_x5 (x44::PK_STP);           // arm 2 x POSITIONAL
  lfst u_x6 (.p_i (x44::PK_SCAT));   // arm 2 x CONCAT Rhs (not a pattern)

  // ===== bare controls: must not move ====================================
  lfst u_xb1 (.p_i (PK_STP));        // BARE aggregate
  lf16 u_xb2 (.p_i (PK_PLN));        // BARE scalar (§ 43 folds)
endmodule

// qh27 — THE PASS-27 FRONTIER, corrected from qf26.
// bis27 (pass-26 binary) lands at tlul_adapter_host.sv:90:16
//   `a_size: top_pkg::TL_SZW'(WordSize),`
// depth 7, r=-6, DIRECTION: LHS(golden) = a LOC-LESS `int_typespec
// {signed=0 val=UINT:2}` / RHS(ours) = an `integer_typespec` AT THE WRITTEN
// SPAN (:90:16).  Both sides DO emit the op=67 cast operation and its
// ref_typespec, so the fix REPLACES the Actual_typespec KIND.
//
// WHY qf26 DID NOT REPRODUCE IT: qf26's `localparam int unsigned WordSize = 2`
// is LITERAL-initialised, so our emitter FOLDS the whole cast to a constant and
// the head became a fold difference instead.  The corpus operand is
// `localparam int WordSize = $clog2(top_pkg::TL_DBW)` — a NON-literal init, so
// the cast survives as an operation on both sides and the typespec KIND is the
// only difference.  That distinction is the point of this file.
//
// Rows: the size-cast in five contexts, each with a NON-folding operand, plus
// the folding operand as the control (row F).
package qh27_pkg;
  localparam int unsigned TL_SZW = 2;
  localparam int unsigned TL_DBW = 4;
  localparam int          SSZW   = 2;   // explicitly SIGNED cast width
endpackage

module qh27
  import qh27_pkg::*;
(
    input  logic [31:0] a_i,
    output logic [1:0]  s_pkg_o,
    output logic [1:0]  s_unq_o,
    output logic [1:0]  s_mod_o,
    output logic [1:0]  s_lit_o,
    output logic [1:0]  s_sgn_o,
    output logic [1:0]  s_fold_o
);
  // NON-literal init: the emitter cannot fold a cast of this.
  localparam int WordSize = $clog2(qh27_pkg::TL_DBW);
  localparam int unsigned MSZW = 2;
  localparam int unsigned Lit  = 2;

  typedef struct packed {
    logic [1:0] a_size;
    logic [3:0] a_mask;
  } tl_t;
  tl_t t_o;

  // A: the cast written QUALIFIED, on a plain cont_assign.
  assign s_pkg_o  = qh27_pkg::TL_SZW'(WordSize);
  // B: the same cast written UNQUALIFIED (wildcard-imported).
  assign s_unq_o  = TL_SZW'(WordSize);
  // C: the cast size is a MODULE localparam.
  assign s_mod_o  = MSZW'(WordSize);
  // D: control — a literal cast width.
  assign s_lit_o  = 2'(WordSize);
  // E: the cast width is an explicitly SIGNED package localparam.
  assign s_sgn_o  = qh27_pkg::SSZW'(WordSize);
  // F: control — the operand folds (literal-initialised localparam).
  assign s_fold_o = qh27_pkg::TL_SZW'(Lit);

  // G: THE CORPUS SHAPE — the cast is a MEMBER VALUE of a struct assignment
  // pattern assigned in one cont_assign.
  assign t_o = '{
      a_size: qh27_pkg::TL_SZW'(WordSize),
      a_mask: {qh27_pkg::TL_DBW{1'b1}}
  };
endmodule

// qf26 — the PASS-26 EXIT FRONTIER, written before any code was touched for it.
// bis26 (after this pass's three changes) lands on
//   tlul_adapter_host.sv:90:16   `a_size: top_pkg::TL_SZW'(WordSize),`
// inside the struct assignment pattern of `assign tl_o = '{...}`, depth 7,
// r=-6.  DIRECTION: LHS(golden) = a LOC-LESS `int_typespec {signed=0
// val=UINT:2}` / RHS(ours) = an `integer_typespec` AT THE WRITTEN SPAN
// (:90:16) — so the fix REPLACES the typespec KIND (and gives it the cast
// width as a VALUE), it neither adds nor removes a pointer.
// This is the same family as the long-standing work@sram2tlul residue ("its
// kept top_pkg::TL_SZW cast").
// Rows, coarse to fine, so the next pass can bisect the CONTEXT as well as the
// cast: a bare cont-assign cast, the same cast inside a struct assignment
// pattern (the corpus shape), a cast whose size is a MODULE localparam rather
// than a package one, and a cast to a LITERAL width as the control.
package qf26_pkg;
  localparam int unsigned TL_SZW = 2;
  localparam int unsigned TL_DBW = 4;
endpackage

module qf26
  import qf26_pkg::*;
(
    input  logic [31:0] a_i,
    output logic [1:0]  s_pkg_o,
    output logic [1:0]  s_unq_o,
    output logic [1:0]  s_mod_o,
    output logic [1:0]  s_lit_o
);
  localparam int unsigned WordSize = 2;
  localparam int unsigned MSZW     = 2;

  typedef struct packed {
    logic [1:0] a_size;
    logic [3:0] a_mask;
  } tl_t;
  tl_t t_o;

  // A: the cast written QUALIFIED, on a plain cont_assign.
  assign s_pkg_o = qf26_pkg::TL_SZW'(WordSize);
  // B: the same cast written UNQUALIFIED (wildcard-imported).
  assign s_unq_o = TL_SZW'(WordSize);
  // C: the size is a MODULE localparam.
  assign s_mod_o = MSZW'(WordSize);
  // D: control — a literal cast width.
  assign s_lit_o = 2'(WordSize);
  // E: THE CORPUS SHAPE — the cast is a MEMBER VALUE of a struct assignment
  // pattern assigned in one cont_assign.
  assign t_o = '{
      a_size: qf26_pkg::TL_SZW'(WordSize),
      a_mask: {qf26_pkg::TL_DBW{1'b1}}
  };
endmodule

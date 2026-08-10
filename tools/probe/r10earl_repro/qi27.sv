// qi27 — THE PASS-27 FRONTIER, second cut.  qh27 proved the DEF view already
// agrees with golden on all seven cast spellings, so the corpus difference is in
// the ELABORATED INSTANCE view — and tlul_adapter_host is an INSTANTIATED CHILD
// (top_earlgrey -> u_rv_core_ibex -> tl_adapter_host_i_ibex), never a top
// module, which qh27 was.  This file instantiates the carrier as a child and
// mirrors the corpus shape exactly:
//   * the cast width is a PACKAGE localparam declared `int` (SIGNED) whose
//     initializer is an EXPRESSION ($clog2), like top_pkg::TL_SZW,
//   * the cast operand is a MODULE localparam with an EXPRESSION initializer,
//     like tlul_adapter_host's `localparam int WordSize = $clog2(TL_DBW)`,
//   * the cast is a MEMBER VALUE of a struct assignment pattern whose OTHER
//     members are NON-CONSTANT ports, so the pattern cannot fold away,
//   * the struct type is a PACKAGE typedef, not a local one.
// Rows vary only the written qualification and the width parameter's home, so
// the DEF and ELAB view of each can be read off cast27.py side by side.
package qi27_pkg;
  localparam int TL_DW  = 32;
  localparam int TL_DBW = (TL_DW >> 3);
  localparam int TL_SZW = $clog2($clog2(TL_DBW) + 1);
  localparam int unsigned USZW = 2;

  typedef struct packed {
    logic [1:0]  a_size;
    logic [3:0]  a_mask;
    logic [31:0] a_data;
  } tl_t;
endpackage

module qi27_child
  import qi27_pkg::*;
#(
  parameter int unsigned MAX_REQS = 2
) (
  input  logic [31:0]   wdata_i,
  input  logic [3:0]    be_i,
  output qi27_pkg::tl_t tl_o,
  output logic [1:0]    s_pkg_o,
  output logic [1:0]    s_unq_o,
  output logic [1:0]    s_mod_o,
  output logic [1:0]    s_lit_o,
  output logic [1:0]    s_uns_o
);
  // EXPRESSION initializer, exactly like the corpus.
  localparam int WordSize = $clog2(qi27_pkg::TL_DBW);
  localparam int MSZW     = $clog2(qi27_pkg::TL_DBW) + 1;

  // THE CORPUS SHAPE: a member value of a struct assignment pattern whose
  // other members are ports.
  assign tl_o = '{
      a_size: qi27_pkg::TL_SZW'(WordSize),
      a_mask: be_i,
      a_data: wdata_i
  };

  // The same casts on plain cont_assigns, for the DEF/ELAB contrast.
  assign s_pkg_o = qi27_pkg::TL_SZW'(WordSize);
  assign s_unq_o = TL_SZW'(WordSize);
  assign s_mod_o = MSZW'(WordSize);
  assign s_lit_o = 2'(WordSize);
  assign s_uns_o = qi27_pkg::USZW'(WordSize);
endmodule

module qi27 (
    input  logic [31:0]   wdata_i,
    input  logic [3:0]    be_i,
    output qi27_pkg::tl_t tl_o,
    output logic [1:0]    s_pkg_o,
    output logic [1:0]    s_unq_o,
    output logic [1:0]    s_mod_o,
    output logic [1:0]    s_lit_o,
    output logic [1:0]    s_uns_o
);
  qi27_child #(.MAX_REQS(2)) u_c (
      .wdata_i(wdata_i),
      .be_i(be_i),
      .tl_o(tl_o),
      .s_pkg_o(s_pkg_o),
      .s_unq_o(s_unq_o),
      .s_mod_o(s_mod_o),
      .s_lit_o(s_lit_o),
      .s_uns_o(s_uns_o)
  );
endmodule

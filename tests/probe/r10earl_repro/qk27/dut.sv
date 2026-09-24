// qk27 — THE NEW FRONTIER after § castQualPkgWidthElabBareTs27.
// bis27 now lands one operand LATER in the very same struct assignment pattern:
//   [5] rel=97[4]  A ref_obj 'tl_source' tlul_adapter_host.sv:92:16
//                  B ref_obj 'tl_be'                        :91:16
// i.e. the operand VECTORS are the same SIZE and the ORDER differs.  The written
// order in tlul_adapter_host is
//   a_valid a_opcode a_param a_size a_mask a_source a_address a_data a_user
//   d_ready
// while tlul_pkg::tl_h2d_t DECLARES
//   a_valid a_opcode a_param a_size a_source a_address a_mask a_data a_user
//   d_ready
// so the hypothesis is: LHS(golden) orders a NAMED struct assignment pattern's
// operands by the STRUCT MEMBER DECLARATION order, RHS(ours) by the WRITTEN
// order.  Rows: shuffled-written (the corpus shape), declaration-order written
// (the control that must not move), and a POSITIONAL pattern (no member names at
// all, where the two orders coincide by definition).  A child instance, so the
// DEF and the ELAB view are both measured.
package qk27_pkg;
  typedef struct packed {
    logic [1:0]  m_a;
    logic [3:0]  m_b;
    logic [7:0]  m_c;
    logic [15:0] m_d;
  } sh_t;
endpackage

module qk27_child (
  input  logic [1:0]   a_i,
  input  logic [3:0]   b_i,
  input  logic [7:0]   c_i,
  input  logic [15:0]  d_i,
  output qk27_pkg::sh_t shuf_o,
  output qk27_pkg::sh_t decl_o,
  output qk27_pkg::sh_t pos_o
);
  // SHUFFLED written order (the corpus shape: c and b swapped, d before them).
  assign shuf_o = '{
      m_a: a_i,
      m_d: d_i,
      m_c: c_i,
      m_b: b_i
  };
  // CONTROL — written in declaration order.
  assign decl_o = '{
      m_a: a_i,
      m_b: b_i,
      m_c: c_i,
      m_d: d_i
  };
  // CONTROL — POSITIONAL pattern, no member names.
  assign pos_o = '{a_i, b_i, c_i, d_i};
endmodule

module qk27 (
    input  logic [1:0]   a_i,
    input  logic [3:0]   b_i,
    input  logic [7:0]   c_i,
    input  logic [15:0]  d_i,
    output qk27_pkg::sh_t shuf_o,
    output qk27_pkg::sh_t decl_o,
    output qk27_pkg::sh_t pos_o
);
  qk27_child u_c (
      .a_i(a_i), .b_i(b_i), .c_i(c_i), .d_i(d_i),
      .shuf_o(shuf_o), .decl_o(decl_o), .pos_o(pos_o)
  );
endmodule

// qj27 — THE UNMEASURED HALF of qi27.  qi27 reproduced the frontier but its
// five plain cont_assign casts all FOLD in the elaborated view (constant
// operand), so the only ELAB row it measures is the struct-pattern one.  Here
// every cast operand is a PORT, so no cast can fold and the ELAB view carries
// one op67 row per spelling: qualified package / unqualified package /
// module localparam / literal / package `int unsigned` / a module parameter.
// LHS(golden) is the g.dump column of cast27.py.
package qj27_pkg;
  localparam int TL_DW  = 32;
  localparam int TL_DBW = (TL_DW >> 3);
  localparam int TL_SZW = $clog2($clog2(TL_DBW) + 1);   // int, computed init
  localparam int unsigned USZW = 2;                     // int unsigned, literal

  typedef struct packed {
    logic [1:0]  a_size;
    logic [3:0]  a_mask;
    logic [31:0] a_data;
  } tl_t;
endpackage

module qj27_child
  import qj27_pkg::*;
#(
  parameter int unsigned PSZW = 2
) (
  input  logic [31:0]   wdata_i,
  input  logic [3:0]    be_i,
  output qj27_pkg::tl_t tl_o,
  output logic [1:0]    s_pkg_o,
  output logic [1:0]    s_unq_o,
  output logic [1:0]    s_mod_o,
  output logic [1:0]    s_lit_o,
  output logic [1:0]    s_uns_o,
  output logic [1:0]    s_par_o
);
  localparam int MSZW = $clog2(qj27_pkg::TL_DBW);

  // THE CORPUS SHAPE, with a non-constant sibling member.
  assign tl_o = '{
      a_size: qj27_pkg::TL_SZW'(be_i),
      a_mask: be_i,
      a_data: wdata_i
  };

  // The same six spellings on plain cont_assigns, all with a PORT operand so
  // the elaborated view cannot fold them away.
  assign s_pkg_o = qj27_pkg::TL_SZW'(be_i);
  assign s_unq_o = TL_SZW'(be_i);
  assign s_mod_o = MSZW'(be_i);
  assign s_lit_o = 2'(be_i);
  assign s_uns_o = qj27_pkg::USZW'(be_i);
  assign s_par_o = PSZW'(be_i);
endmodule

module qj27 (
    input  logic [31:0]   wdata_i,
    input  logic [3:0]    be_i,
    output qj27_pkg::tl_t tl_o,
    output logic [1:0]    s_pkg_o,
    output logic [1:0]    s_unq_o,
    output logic [1:0]    s_mod_o,
    output logic [1:0]    s_lit_o,
    output logic [1:0]    s_uns_o,
    output logic [1:0]    s_par_o
);
  qj27_child #(.PSZW(2)) u_c (
      .wdata_i(wdata_i),
      .be_i(be_i),
      .tl_o(tl_o),
      .s_pkg_o(s_pkg_o),
      .s_unq_o(s_unq_o),
      .s_mod_o(s_mod_o),
      .s_lit_o(s_lit_o),
      .s_uns_o(s_uns_o),
      .s_par_o(s_par_o)
  );
endmodule

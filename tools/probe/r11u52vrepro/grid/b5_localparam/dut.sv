// b5 — the NAME the bound resolves to.  The law emits the written identifier
// through emitSyntaxExpr with syntaxRefPrefix CLEARED; the identifier may be a
// module PARAMETER, a module LOCALPARAM, a GENVAR-free constant, or a name
// from a PACKAGE imported into the body.  Each resolves in a different scope;
// golden names each one its own way.
package cfg_pkg;
  parameter int PW = 6;
endpackage

module dut #(parameter int N = 4, parameter int DEPTH = 8) (
  input logic clk,
  output logic o
);
  import cfg_pkg::*;
  localparam int LP = N + 2;

  // parameter bound (the law's own cell)
  typedef logic [N-1:0] t_par [DEPTH];
  // LOCALPARAM bound
  typedef logic [LP-1:0] t_lp [DEPTH];
  // WILDCARD-IMPORTED package parameter
  typedef logic [PW-1:0] t_imp [DEPTH];
  // EXPLICITLY SCOPED package parameter -> a ScopedName, not a bare identifier
  typedef logic [cfg_pkg::PW-1:0] t_scoped [DEPTH];

  t_par a_par; t_lp a_lp; t_imp a_imp; t_scoped a_scoped;
  assign o = a_par[0][0] ^ a_lp[0][0] ^ a_imp[0][0] ^ a_scoped[0][0];
endmodule

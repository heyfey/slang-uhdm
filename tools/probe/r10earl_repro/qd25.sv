// qd25 — qc25's g_mu row (module `localparam int unsigned` as an UNPACKED
// dimension in a gen scope) came out cmp-EQUAL, so qc25 does NOT reproduce the
// pass-25 second frontier at ibex_core.sv:923:32.  What the corpus has and
// qc25 lacks is the CHILD-INSTANCE / PARAMETER-OVERRIDE half:
//   * the gen scope's condition is a MODULE PARAMETER (`if (PMPEnable)`), not
//     a literal, and that parameter is OVERRIDDEN at instantiation;
//   * ibex_core sits TWO levels down (top > u_rv_core_ibex > u_core) and its
//     enclosing instance is itself parameterised;
//   * the localparam PMP_NUM_CHAN is declared AFTER the parameter port list,
//     inside the body, next to other localparams derived from parameters.
// Rows below add exactly those, one at a time, keeping qc25's g_mu spelling.
package qd25_pkg;
  typedef enum logic [1:0] { PL_U = 2'b00, PL_M = 2'b11 } pl_t;
endpackage

// L3 — the DEEPEST module: gen-scope condition is an overridden parameter.
module qd25_leaf #(
    parameter bit          EN   = 1'b0,
    parameter int unsigned NREG = 4
) (
    input  logic c,
    output logic o1, o2
);
  import qd25_pkg::*;
  localparam int unsigned NCH = 2;

  if (EN) begin : g_pmp
    logic [33:0] p_addr [NCH];
    pl_t         p_type [NCH];
    pl_t         p_priv [NCH];
    assign o1 = p_addr[0][0] | (p_type[0] == PL_U) | (p_priv[0] == PL_M);
  end
  else begin : g_no
    assign o1 = 1'b0;
  end
  assign o2 = c;
endmodule

// L2 — the middle level, itself parameterised (rv_core_ibex's role).
module qd25_mid #(
    parameter bit          PMPEnable     = 1'b0,
    parameter int unsigned PMPNumRegions = 4
) (
    input  logic c,
    output logic o1, o2
);
  qd25_leaf #(
      .EN   (PMPEnable),
      .NREG (PMPNumRegions)
  ) u_core (.c(c), .o1(o1), .o2(o2));
endmodule

module qd25 (
    input  logic c,
    output logic o1, o2
);
  qd25_mid #(
      .PMPEnable     (1'b1),
      .PMPNumRegions (16)
  ) u_mid (.c(c), .o1(o1), .o2(o2));
endmodule

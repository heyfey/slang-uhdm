// qc25 — the frontier AFTER pass-25 law 1: ibex_core.sv:923:32.
//   if (PMPEnable) begin : g_pmp
//     priv_lvl_e pmp_priv_lvl [PMP_NUM_CHAN];
// The UNPACKED dimension folds its unqualified wildcard-imported package
// parameter into an operation, and the operand constant carries a
// ref_typespec in OURS while GOLDEN has NONE (bis25: A=<null> /
// B=ref_typespec, r=-1 — i.e. WE STAMP, GOLDEN LACKS, so the fix SUPPRESSES).
// Note this points the OPPOSITE way from pass-24 residue (5), where golden
// stamps a ref_typespec on a TOP-LEVEL gen scope's pkg-param fold and we lack
// it — hence the two rows T* below, which put both shapes in one file.
package qc25_pkg;
  localparam int unsigned NCH = 2;
  parameter  int unsigned PCH = 2;
  localparam int          SCH = 2;          // TYPED signed
  localparam              UCH = 2;          // UNTYPED
  typedef enum logic [1:0] { PL_U = 2'b00, PL_M = 2'b11 } pl_t;
endpackage

module qc25_sink
  import qc25_pkg::*;
#(
    parameter int unsigned NCHAN = 2
) (
    input pl_t priv_i [NCHAN]
);
  logic unused;
  assign unused = (priv_i[0] == PL_U);
endmodule

module qc25_child
  import qc25_pkg::*;
(
    input  logic c,
    output logic o1, o2, o3, o4, o5, o6, o7, o8
);
  // MODULE localparams — the corpus's own spelling (ibex_core.sv:108).
  localparam int unsigned MNCH = 2;
  localparam int          MSCH = 2;
  localparam              MUCH = 2;

  // M* — the SAME declarations at MODULE level (controls).
  pl_t        m_arr [NCH];
  logic [1:0] m_pk  [NCH];
  // MM* — a MODULE-LEVEL declaration using the SAME module localparam the gen
  // scope uses.  The corpus has exactly this (ibex_core.sv:255
  // `logic pmp_req_err [PMP_NUM_CHAN];` beside :921-923's three gen-scope
  // declarations), and it is the last feature qc25 lacked.
  logic       mm_err [MNCH];
  assign o1 = (m_arr[0] == PL_U) | m_pk[0][0] | mm_err[0];

  if (1) begin : g_pmp
    // G1 — the CORPUS shape exactly: enum element type, unpacked dim, an
    // UNQUALIFIED wildcard-imported package LOCALPARAM.
    pl_t        g_pl  [NCH];
    // G2 — logic-vector element, same dim (ibex_core.sv:921).
    logic [1:0] g_lv  [NCH];
    // G3 — the QUALIFIED spelling of the same dim.
    pl_t        g_q   [qc25_pkg::NCH];
    // G4 — a PACKED range over the same parameter.
    logic [NCH-1:0] g_pk;
    // G5 — the explicit `[0:N-1]` spelling.
    pl_t        g_ex  [0:NCH-1];
    // G6 — a package PARAMETER (not localparam) as the dim.
    pl_t        g_pp  [PCH];
    // G7 — a TYPED-signed and an UNTYPED package localparam as the dim.
    pl_t        g_s   [SCH];
    pl_t        g_u   [UCH];
    // G8..G11 — THE CORPUS SHAPE: the dimension is a MODULE LOCALPARAM
    // (ibex_core.sv:108 `localparam int unsigned PMP_NUM_CHAN = 2;`), not a
    // package one.  Four spellings of the declaration.
    pl_t        g_mu  [MNCH];    // localparam int unsigned
    pl_t        g_ms  [MSCH];    // localparam int          (signed)
    pl_t        g_mn  [MUCH];    // localparam (untyped)
    logic [1:0] g_ml  [MNCH];    // logic-vector element, same dim
    assign o2 = (g_pl[0] == PL_U) | g_lv[0][0] | (g_q[0] == PL_M);
    assign o3 = g_pk[0] | (g_ex[0] == PL_U) | (g_pp[0] == PL_M);
    assign o4 = (g_s[0] == PL_U) | (g_u[0] == PL_M) | (g_mu[0] == PL_U) |
                (g_ms[0] == PL_M) | (g_mn[0] == PL_U) | g_ml[0][0];
    // G12 — the last corpus feature qc25 lacks: a CHILD INSTANCE inside the
    // same gen scope whose port actual is the WHOLE unpacked array
    // (ibex_core.sv:930 `ibex_pmp ... .priv_mode_i (pmp_priv_lvl)`).
    qc25_sink #(.NCHAN (MNCH)) u_sink (.priv_i (g_mu));
  end

  if (1) begin : g_out
    if (1) begin : g_in
      // N1 — the same shape in a NESTED gen scope.
      pl_t n_pl [NCH];
      assign o5 = (n_pl[0] == PL_U);
    end
  end

  for (genvar k = 0; k < 2; k++) begin : g_for
    pl_t f_pl [NCH];
    if (k == 0) assign o6 = (f_pl[0] == PL_U);
  end

  assign o7 = c;
  assign o8 = 1'b0;
endmodule

module qc25
  import qc25_pkg::*;
(
    input  logic c,
    output logic o1, o2, o3, o4, o5, o6, o7, o8,
    output logic t1, t2
);
  qc25_child u_c (.c(c), .o1(o1), .o2(o2), .o3(o3), .o4(o4), .o5(o5),
                  .o6(o6), .o7(o7), .o8(o8));

  // T* — the TOP-MODULE gen scope halves (pass-24 residue (5)'s shape).
  if (1) begin : t_if
    pl_t t_pl [NCH];
    assign t1 = (t_pl[0] == PL_U);
  end

  for (genvar k = 0; k < 2; k++) begin : t_flat
    pl_t t_fl [NCH];
    if (k == 0) assign t2 = (t_fl[0] == PL_U);
  end
endmodule

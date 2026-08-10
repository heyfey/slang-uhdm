// qe26 — pass-26 residue (2)+(3): the UNPACKED-DIMENSION folded-bound constant.
// qc25 left TWO halves unmeasured:
//   * its only QUALIFIED row (g_q) was an `int unsigned` pkg localparam, so
//     "qualified -> ADD the ref_typespec" has never been seen on a SIGNED or an
//     UNTYPED pkg param, nor on a pkg `parameter`.
//   * it never tried a module-level `parameter` (un-overridden) or an
//     EXPLICIT single-name import, so "package scope -> golden stamps NOTHING"
//     may really be "wildcard import -> nothing".
// Every row below is the SAME declaration shape — `pl_t X [P];` inside one
// if-generate of a CHILD instance — varying ONLY the dimension parameter's
// home, its written qualification and its declared type.
// DIRECTION CONVENTION: LHS(golden) is the `<` side of dvd26.sh's diff.
package qe26_pkg;
  localparam int unsigned PU  = 2;   // qc25 G1  (equal)
  localparam int          PS  = 2;   // qc25 G7a (golden NO ts, ours ts)
  localparam              PN  = 2;   // qc25 G7b (golden NO ts sz64, ours ts sz32)
  parameter  int unsigned QU  = 2;   // qc25 G6  (equal)
  parameter               QN  = 2;   // NEW: untyped pkg PARAMETER
  typedef enum logic [1:0] { PL_U = 2'b00, PL_M = 2'b11 } pl_t;
endpackage

module qe26_sink #(
    parameter int unsigned NCHAN = 2
) (
    input logic [1:0] priv_i [NCHAN]
);
  logic unused;
  assign unused = priv_i[0][0];
endmodule

// THE UNMEASURED HALF THE EXISTENCE CENSUS FOUND: every override row in the
// original qe26 sized its port with an `int unsigned` parameter, so
// § dimFoldTsQualifiedOrSignedModPar26's "module + explicit + SIGNED -> stamp"
// arm was never exercised on an OVERRIDDEN parameter.  The corpus has three
// (rv_timer mtimecmp [N], rv_plic prio [N_SOURCE], prim_ram_1p mem [Depth]).
module qe26_ssink #(
    parameter int SCH = 2            // TYPED and SIGNED, and overridden below
) (
    input logic [1:0] s_i [SCH]
);
  logic sunused;
  assign sunused = s_i[0][0];
endmodule

module qe26_mid #(
    parameter int unsigned MCH = 2
) (
    input logic [1:0] mid_i [MCH]
);
  qe26_sink #(.NCHAN (MCH)) u_deep (.priv_i (mid_i));
endmodule

module qe26_child
  import qe26_pkg::*;
(
    input  logic c,
    output logic o1, o2, o3, o4
);
  localparam int unsigned MU  = 2;   // qc25 G8  (equal)
  localparam int          MS  = 2;   // qc25 G9  (equal: ts on BOTH sides)
  localparam              MN  = 2;   // qc25 G10 (golden NO ts, ours ts)
  parameter  int unsigned RU  = 2;   // NEW: module PARAMETER, un-overridden
  parameter               RN  = 2;   // NEW: module PARAMETER, untyped
  // DISTINCT VALUES for the override-chain rows below.  They must differ:
  // slang shares ONE instance body between instantiations whose parameter
  // VALUES agree, so four sinks all sized 2 collapse to one ParameterSymbol
  // and no per-instance rule can be measured (this cost pass 26 one build).
  localparam int unsigned MV  = 5;   // for the two-level chain
  localparam int unsigned MW  = 7;   // for the module-level control

  if (1) begin : g_s
    // --- the qc25 rows, repeated so this file is self-contained ---
    pl_t a_pu  [PU];               // pkg localparam int unsigned, UNQUAL
    pl_t a_ps  [PS];               // pkg localparam int (signed),  UNQUAL
    pl_t a_pn  [PN];               // pkg localparam untyped,       UNQUAL
    pl_t a_qu  [QU];               // pkg parameter int unsigned,   UNQUAL
    pl_t a_mu  [MU];               // module localparam int unsigned
    pl_t a_ms  [MS];               // module localparam int (signed)
    pl_t a_mn  [MN];               // module localparam untyped
    // --- THE UNMEASURED HALF OF "QUALIFIED -> ADD" ---
    pl_t b_qpu [qe26_pkg::PU];     // QUALIFIED, int unsigned  (= qc25 g_q)
    pl_t b_qps [qe26_pkg::PS];     // QUALIFIED, int (signed)      NEW
    pl_t b_qpn [qe26_pkg::PN];     // QUALIFIED, untyped           NEW
    pl_t b_qqu [qe26_pkg::QU];     // QUALIFIED pkg parameter      NEW
    pl_t b_qqn [qe26_pkg::QN];     // QUALIFIED untyped pkg param  NEW
    pl_t a_qn  [QN];               // UNQUAL   untyped pkg param   NEW
    // --- THE UNMEASURED MODULE-PARAMETER ROWS ---
    pl_t c_ru  [RU];               // module parameter int unsigned NEW
    pl_t c_rn  [RN];               // module parameter untyped      NEW
    assign o1 = (a_pu[0] == PL_U) | (a_ps[0] == PL_M) | (a_pn[0] == PL_U) |
                (a_qu[0] == PL_M) | (a_mu[0] == PL_U) | (a_ms[0] == PL_M) |
                (a_mn[0] == PL_U);
    assign o2 = (b_qpu[0] == PL_U) | (b_qps[0] == PL_M) | (b_qpn[0] == PL_U) |
                (b_qqu[0] == PL_M) | (b_qqn[0] == PL_U) | (a_qn[0] == PL_M) |
                (c_ru[0] == PL_U) | (c_rn[0] == PL_M);
    // --- residue (3): a CHILD INSTANCE inside the gen scope whose PORT's
    // unpacked dimension is the instance's OWN parameter, OVERRIDDEN from
    // here.  qc25 G12: golden sizes the folded bound 32, we size it 64.
    // Four override actuals, one per instance.
    logic [1:0] d_mu [MU];
    logic [1:0] d_3  [3];
    logic [1:0] d_ru [RU];
    logic [1:0] d_mv [MV];
    qe26_sink #(.NCHAN (MU)) u_lit  (.priv_i (d_mu));   // actual = literal-init localparam
    qe26_sink #(.NCHAN (3))  u_num  (.priv_i (d_3));    // actual = a bare literal
    qe26_sink #(.NCHAN (RU)) u_par  (.priv_i (d_ru));   // actual = literal-init module PARAMETER
    qe26_mid  #(.MCH   (MV)) u_two  (.mid_i  (d_mv));   // TWO levels: the inner actual is a REF
    // The SIGNED-TYPED overridden parameter, narrow chain and literal chain:
    // does golden stamp the ts law 1 gives a signed module parameter, or does
    // the OVERRIDE suppress it (§ overriddenBoundParamNoFoldTs19's claim in the
    // PACKED builder)?
    logic [1:0] d_s1 [MU];
    logic [1:0] d_s2 [11];
    qe26_ssink #(.SCH (MU)) u_sn (.s_i (d_s1));  // narrow chain
    qe26_ssink #(.SCH (11)) u_sl (.s_i (d_s2));  // literal chain
  end

  // MODULE-LEVEL controls for the same instantiations (distinct values again).
  logic [1:0] m_mu [MW];
  logic [1:0] m_9  [9];
  qe26_sink #(.NCHAN (MW)) m_lit (.priv_i (m_mu));
  qe26_sink #(.NCHAN (9))  m_num (.priv_i (m_9));
  assign o3 = c | m_mu[0][0];
  assign o4 = 1'b0;
endmodule

// Does "package scope -> golden stamps nothing" really mean the WILDCARD
// import?  Same rows behind an EXPLICIT single-name import.
module qe26_child2
  import qe26_pkg::PS;
  import qe26_pkg::PN;
  import qe26_pkg::PU;
  import qe26_pkg::pl_t;
(
    output logic e1
);
  if (1) begin : g_e
    pl_t e_pu [PU];
    pl_t e_ps [PS];
    pl_t e_pn [PN];
    assign e1 = (e_pu[0] == qe26_pkg::PL_U) | (e_ps[0] == qe26_pkg::PL_M) |
                (e_pn[0] == qe26_pkg::PL_U);
  end
endmodule

module qe26 (
    input  logic c,
    output logic o1, o2, o3, o4, e1
);
  qe26_child  u_c  (.c(c), .o1(o1), .o2(o2), .o3(o3), .o4(o4));
  qe26_child2 u_c2 (.e1(e1));
endmodule

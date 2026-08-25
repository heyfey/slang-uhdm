// r10v89 va4 — THE `cts` RECURSION'S QUALIFICATION COUPLING.  GOLDEN = Surelog.
// `paramValueSigned89` walks a BARE-REFERENCE initializer and refuses the hop
// unless `inPackage89(referenced) == (the reference is spelled ScopedName)`.
// Every cross-combination of that test is measured here, plus the homes the
// walk can cross: package -> module, module -> package -> module, an
// INTERFACE parameter, a hierarchical reference, and a compilation-unit
// ($unit) parameter.
package pw89;
  localparam int          W_INT = 4;
  localparam int unsigned W_IU  = 4;
  localparam              W_UN  = 4;
  localparam int          W_FROM_UNIT = 4;
endpackage

package px89;
  import pw89::*;
  localparam int unsigned X_FROM_BARE = W_INT;        // pkg param, BARE ref
  localparam int unsigned X_FROM_QUAL = pw89::W_INT;  // pkg param, QUAL ref
  localparam int          X_INT       = 4;
  localparam int unsigned X_LOCAL     = X_INT;        // SAME-package BARE ref
  localparam int          X_I_FROM_QU = pw89::W_IU;   // int sink, unsigned src
endpackage

interface iw89 ();
  import pw89::*;
  localparam int          IW_S = 3 + 1;
  localparam int unsigned IW_U = 3 + 1;
  localparam int unsigned IW_FB = W_INT;         // pkg param, BARE, in an iface
  localparam int unsigned IW_FQ = pw89::W_INT;   // pkg param, QUAL, in an iface
  logic [3:0] iw_s  [IW_S];
  logic [3:0] iw_u  [IW_U];
  logic [3:0] iw_fb [IW_FB];
  logic [3:0] iw_fq [IW_FQ];
endinterface

module va4_89;
  import pw89::*;
  localparam int          M_INT = 4;
  localparam int unsigned M_IU  = 4;

  // ---- a MODULE localparam whose bare-ref initializer names a PACKAGE
  //      parameter, spelled BARE (imported) and QUALIFIED ------------------
  localparam int unsigned q_bare = W_INT;        logic [3:0] v_q_bare [q_bare];
  localparam int unsigned q_qual = pw89::W_INT;  logic [3:0] v_q_qual [q_qual];
  localparam int unsigned q_qu   = pw89::W_IU;   logic [3:0] v_q_qu   [q_qu];
  localparam int unsigned q_qun  = pw89::W_UN;   logic [3:0] v_q_qun  [q_qun];
  localparam int          q_i_qu = pw89::W_IU;   logic [3:0] v_q_i_qu [q_i_qu];

  // ---- a MODULE localparam naming a PACKAGE localparam that itself names
  //      another package parameter (module -> package -> package) ---------
  localparam int unsigned q_2b = px89::X_FROM_BARE; logic [3:0] v_q_2b [q_2b];
  localparam int unsigned q_2q = px89::X_FROM_QUAL; logic [3:0] v_q_2q [q_2q];

  // ---- the package parameters read DIRECTLY as bounds -------------------
  logic [3:0] v_pb_int [W_INT];
  logic [3:0] v_pq_int [pw89::W_INT];
  logic [3:0] v_pb_x   [px89::X_FROM_BARE];

  // ---- an INTERFACE parameter, read INSIDE the interface ---------------
  //      (a hierarchical `u_iw.IW_S` is not a constant expression in SV, so
  //       the interface's own body is the only home this face has).
  iw89 u_iw ();

  // ---- deeper QUALIFIED chains through a package intermediate ----------
  localparam int unsigned q_3q  = px89::X_LOCAL;     logic [3:0] v_q_3q  [q_3q];
  localparam int unsigned q_xi  = px89::X_INT;       logic [3:0] v_q_xi  [q_xi];
  localparam int unsigned q_xiq = px89::X_I_FROM_QU; logic [3:0] v_q_xiq [q_xiq];
  localparam int          q_i3q = px89::X_LOCAL;     logic [3:0] v_q_i3q [q_i3q];

  // ---- a MODULE parameter naming a MODULE parameter, spelled BARE ------
  localparam int unsigned q_mm = M_INT;          logic [3:0] v_q_mm [q_mm];
  localparam int          q_mu = M_IU;           logic [3:0] v_q_mu [q_mu];
endmodule

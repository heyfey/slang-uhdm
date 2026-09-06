// r10earl109 arm g5 -- THE MUST-NOT-MOVE HALF.
//
// Every shape an earlier landed pass owns at this same builder, reproduced on a
// STALE-SCOPE child so the new arm is on the stack for all of them:
//   * an OVERRIDDEN `int` parameter bound   -- earl19 overriddenBoundParamNoFoldTs19
//                                              / earl24 boundOverriddenParamWidth24
//                                              / earl82 rangeBoundStoredWidth82
//   * a PACKAGE parameter bound             -- earl82 pkgVarDimBoundEnc82 /
//                                              defNetBoundPkgIntEnc
//   * a $unit (compilation-unit) parameter bound
//   * a GEN-SCOPE localparam bound          -- the bare-32 arm
//   * an UNPACKED parameter dimension       -- earl102 elabRhsArrayTsSubBoundFolds102
//   * an INSTANCE-ARRAY port (elemPortTs sharing)
//   * an INTERFACE port
//   * a NAMED-type (typedef'd vector) port
//   * a struct MEMBER packed dimension
// None of these is a bare, non-overridden, `int`-typed INSTANCE-BODY parameter
// name on an elaborated port, so `elabPortIntBoundParam109` must abstain on
// every one.
// MEASUREMENT ONLY.  LHS is ALWAYS golden.
parameter int UNITP109 = 5;              // $unit scope

package g5_pkg109;
  parameter int PKINT109 = 7;
  typedef logic [PKINT109:0] pvec109_t;
endpackage

interface g5_if109 #(parameter int IFN109 = 4) ();
  logic [IFN109:0] d;
  modport mp (input d);
endinterface

module g5_leaf109 (input logic a_i, output logic b_o);
  assign b_o = ~a_i;
endmodule

module g5_arr109 #(parameter int AW109 = 3) (
  input  logic [AW109:0] a_i,
  output logic           z_o
);
  assign z_o = a_i[0];
endmodule

module g5_kid109
  import g5_pkg109::*;
#(
  parameter  int OVR109  = 5,               // OVERRIDDEN below
  localparam int LOC109  = 6,               // the LAW's own shape, as a control
  parameter  int ARRN109 = 2
) (
  input  logic                  clk_i,
  input  logic [OVR109:0]       n_ovr_i,    // OVERRIDDEN int param -- must not move
  input  logic [PKINT109:0]     n_pki_i,    // PACKAGE param        -- must not move
  input  logic [UNITP109:0]     n_unit_i,   // $unit param          -- must not move
  input  g5_pkg109::pvec109_t   n_tdf_i,    // NAMED typedef vector -- must not move
  input  logic [LOC109:0]       n_loc_i,    // THE LAW's shape      -- moves
  output logic                  q_o
);
  // a struct member packed dimension
  typedef struct packed { logic [LOC109:0] f; logic [OVR109:0] g; } s109_t;
  s109_t s;
  // an unpacked PARAMETER dimension (earl102's family)
  localparam int UPARR109 [0:LOC109-1] = '{0,0,0,0,0,0};
  // a gen-scope localparam bound
  logic gz;
  generate
    for (genvar gi = 0; gi < 2; gi++) begin : gblk
      localparam int GLOC109 = 4;
      logic [GLOC109:0] gv;
      assign gv = {5{clk_i}};
    end
  endgenerate
  assign gz = gblk[0].gv[0];
  // an INSTANCE ARRAY of a child whose port bound names ITS own param
  logic [3:0] az;
  logic [1:0][ARRN109:0] aa;
  g5_arr109 #(.AW109(ARRN109)) u_arr [0:1] (.a_i(aa), .z_o(az[1:0]));
  // an INTERFACE with its own parameterised vector
  g5_if109 #(.IFN109(3)) u_if ();
  logic lb;
  g5_leaf109 u_leaf (.a_i(clk_i), .b_o(lb));
  assign aa = '0;
  assign s = '0;
  assign q_o = lb & gz & az[0] & n_ovr_i[0] & n_pki_i[0] & n_unit_i[0] &
               n_tdf_i[0] & n_loc_i[0] & s.f[0] & (UPARR109[0] == 0) &
               u_if.d[0];
endmodule

module g5_neg109;
  logic clk, q;
  logic [63:0] w;
  g5_kid109 #(.OVR109(9)) u_k (
    .clk_i(clk), .n_ovr_i(w), .n_pki_i(w), .n_unit_i(w), .n_tdf_i(w),
    .n_loc_i(w), .q_o(q));
endmodule

// r10earl89 g3 — HOMES x DECLARATION KINDS x DIMENSION KINDS, one sizing
// parameter shape per column: an `int` localparam whose initializer is an
// EXPRESSION (the head's shape, `localparam int TotalRegions = MpRegions+1`)
// and its `int unsigned` twin (the built-in negative control: golden stamps
// the first and not the second).  GOLDEN = Surelog.
package r89;
  localparam int          RP_S = 3 + 1;
  localparam int unsigned RP_U = 3 + 1;
endpackage

interface if89 ();
  localparam int          I_S = 3 + 1;
  localparam int unsigned I_U = 3 + 1;
  logic [3:0] if_s [I_S];
  logic [3:0] if_u [I_U];
  wire  [3:0] if_ns [I_S];
endinterface

module leaf89 #(parameter int DEPTH = 4) ();
  localparam int          L_S = DEPTH + 1;
  localparam int unsigned L_U = DEPTH + 1;
  logic [3:0] lf_s [L_S];
  logic [3:0] lf_u [L_U];
endmodule

module mid89 ();
  leaf89 u_a ();
  leaf89 #(.DEPTH(5)) u_b ();
endmodule

module g3_89;
  import r89::*;
  localparam int          M_S = 3 + 1;
  localparam int unsigned M_U = 3 + 1;
  localparam int          W2  = 2 + 1;

  // ---- DECLARATION KINDS, module body ---------------------------------
  logic [3:0] d_var_s  [M_S];              // variable, unpacked
  logic [3:0] d_var_u  [M_U];              // (negative control)
  wire  [3:0] d_net_s  [M_S];              // net, unpacked
  wire  [3:0] d_net_u  [M_U];
  logic [3:0] d_2d_s   [M_S][W2];          // two unpacked dims
  logic [M_S-1:0] d_pk_s;                  // PACKED dimension, written bound
  logic [M_U-1:0] d_pk_u;
  logic [3:0] d_q_s    [$];                // queue      (no bound at all)
  logic [3:0] d_aa_s   [int];              // associative(no bound at all)
  typedef logic [3:0] td_s_t [M_S];        // typedef of an unpacked array
  typedef logic [3:0] td_u_t [M_U];
  td_s_t d_td_s;
  td_u_t d_td_u;
  struct packed { logic [M_S-1:0] f; } d_st_s;

  // ---- a PORTED child: input / output / inout unpacked dims ------------
  port89 u_p ();

  // ---- GEN-SCOPE homes -------------------------------------------------
  for (genvar gi = 0; gi < 2; gi++) begin : gb
    localparam int          G_S = gi + 4;
    localparam int unsigned G_U = gi + 4;
    logic [3:0] g_var_s [G_S];
    logic [3:0] g_var_u [G_U];
    logic [3:0] g_out_s [M_S];             // the OUTER parameter, inside a gen scope
  end
  if (1) begin : gi1
    logic [3:0] gi_var_s [M_S];
  end

  // ---- INTERFACE + NESTED INSTANCE homes -------------------------------
  if89 u_if ();
  mid89 u_m1 ();
  mid89 u_m2 ();

  // ---- PACKAGE parameters, bare and qualified --------------------------
  logic [3:0] d_pkg_bare [RP_S];
  logic [3:0] d_pkg_qual [r89::RP_S];
  logic [3:0] d_pkg_qu   [r89::RP_U];

  // ---- a FUNCTION LOCAL, a TASK LOCAL and a CLASS PROPERTY -------------
  function automatic int f89();
    logic [3:0] fn_s [M_S];
    logic [3:0] fn_u [M_U];
    return fn_s[0] + fn_u[0];
  endfunction
  int unused89 = f89();

  class c89;
    logic [3:0] cp_s [M_S];          // class property, unpacked, signed sizer
    logic [3:0] cp_u [M_U];          // ...and its negative control
  endclass
endmodule

module port89
  (input  logic [3:0] p_in_s  [4],
   output logic [3:0] p_out_s [4]);
  localparam int          P_S = 3 + 1;
  localparam int unsigned P_U = 3 + 1;
  logic [3:0] p_body_s [P_S];
  logic [3:0] p_body_u [P_U];
endmodule

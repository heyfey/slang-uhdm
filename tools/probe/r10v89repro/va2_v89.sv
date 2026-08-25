// r10v89 va2 — THE LEAF KINDS the implementer's g1/g2/g4 do NOT reach, chosen
// to BREAK § dimBoundLeafValueSignedTs89 in BOTH directions.  GOLDEN = Surelog.
//   * ENUM-typed sizing parameters in the GENERIC arm (a bare-ref initializer):
//     `getType().isSigned()` says SIGNED for `enum int`, so the PRISTINE
//     emitter stamps; the new predicate excludes `isEnum()`.  Which is right?
//   * PACKED STRUCT / UNION signed sizing parameters: also `isSigned()` on the
//     old test, also excluded by the new one.
//   * scalar `bit signed` / `logic signed` / `reg signed [W-1:0]`.
//   * a 20-HOP `cts` chain, which crosses the new predicate's depth-16 guard.
//   * `time`, and an OVERRIDDEN parameter reaching the REDUCED arm.
//   * a GENVAR read directly as the bound.
package pv89;
  localparam int          PK_S  = 3 + 1;
  localparam int unsigned PK_U  = 3 + 1;
  localparam byte         PK_BY = 4;
endpackage

module va2_sink89 #(parameter int OVI = 4, parameter int unsigned OVU = 4) ();
  logic [3:0] s_ovi   [OVI];
  logic [3:0] s_ovu   [OVU];
  localparam int          h_ovi   = OVI + 0;   // expression init -> REDUCED arm
  localparam int unsigned h_ovu   = OVI + 0;
  logic [3:0] s_h_ovi [h_ovi];
  logic [3:0] s_h_ovu [h_ovu];
endmodule

module va2_89;
  import pv89::*;

  // ---- ENUM-typed sizing parameters -----------------------------------
  typedef enum int              { E0 = 4, E1 = 5 } en_i_t;
  typedef enum int unsigned     { U0 = 4, U1 = 5 } en_u_t;
  typedef enum logic signed [7:0] { S0 = 4, S1 = 5 } en_ls_t;
  localparam en_i_t  e_lit  = E1;      logic [3:0] v_e_lit  [e_lit];
  localparam en_i_t  e_ref  = e_lit;   logic [3:0] v_e_ref  [e_ref];
  localparam en_u_t  e_uref = U1;      logic [3:0] v_e_uref [e_uref];
  localparam en_ls_t e_ls   = S0;      logic [3:0] v_e_ls   [e_ls];
  localparam en_ls_t e_lsr  = e_ls;    logic [3:0] v_e_lsr  [e_lsr];
  localparam int     e_from = e_lit;   logic [3:0] v_e_from [e_from];

  // ---- PACKED STRUCT / UNION sizing parameters ------------------------
  typedef struct packed signed { logic [7:0] a; } sps_t;
  typedef struct packed        { logic [7:0] a; } spu_t;
  typedef union  packed signed { logic [7:0] a; logic [7:0] b; } upk_t;
  localparam sps_t st_s  = 8'd4;   logic [3:0] v_st_s  [st_s];
  localparam spu_t st_u  = 8'd4;   logic [3:0] v_st_u  [st_u];
  localparam sps_t st_sr = st_s;   logic [3:0] v_st_sr [st_sr];
  localparam sps_t st_se = st_s + 0; logic [3:0] v_st_se [st_se];
  localparam upk_t un_s  = 8'd4;     logic [3:0] v_un_s  [un_s];
  localparam upk_t un_se = 8'd3 + 1; logic [3:0] v_un_se [un_se];

  // ---- SCALAR signed leaves -------------------------------------------
  // (a 1-bit SIGNED scalar can only hold 0 or -1, so it can never be a
  //  positive dimension bound: slang rejects `[b_sg]` outright.  The
  //  ScalarType leg of the new predicate is reachable only through a
  //  2-bit-or-wider packed array, which g1 already covers.)
  localparam bit   signed [1:0] b_sg = 1;  logic [3:0] v_b_sg [b_sg];
  localparam logic signed [1:0] l_sg = 1;  logic [3:0] v_l_sg [l_sg];
  localparam int W89 = 8;
  localparam reg   signed [7:0]     r_sg   = 4;    logic [3:0] v_r_sg   [r_sg];
  localparam reg   signed [7:0]     r_sg_e = 3+1;  logic [3:0] v_r_sg_e [r_sg_e];
  localparam logic signed [W89-1:0] w_sg   = 4;    logic [3:0] v_w_sg   [w_sg];
  localparam logic signed [W89-1:0] w_sg_e = 3+1;  logic [3:0] v_w_sg_e [w_sg_e];
  localparam logic        [W89-1:0] w_un_e = 3+1;  logic [3:0] v_w_un_e [w_un_e];

  // ---- `time` ----------------------------------------------------------
  localparam time t_tm = 4;               logic [3:0] v_t_tm [t_tm];
  localparam time t_tm_r = W89 - 4;       logic [3:0] v_t_tm_r [t_tm_r];

  // ---- a 20-HOP `cts` chain (the depth-16 guard) -----------------------
  localparam int          c00 = 4;
  localparam int unsigned c01 = c00; localparam int unsigned c02 = c01;
  localparam int unsigned c03 = c02; localparam int unsigned c04 = c03;
  localparam int unsigned c05 = c04; localparam int unsigned c06 = c05;
  localparam int unsigned c07 = c06; localparam int unsigned c08 = c07;
  localparam int unsigned c09 = c08; localparam int unsigned c10 = c09;
  localparam int unsigned c11 = c10; localparam int unsigned c12 = c11;
  localparam int unsigned c13 = c12; localparam int unsigned c14 = c13;
  localparam int unsigned c15 = c14; localparam int unsigned c16 = c15;
  localparam int unsigned c17 = c16; localparam int unsigned c18 = c17;
  localparam int unsigned c19 = c18; localparam int unsigned c20 = c19;
  logic [3:0] v_c01 [c01];
  logic [3:0] v_c10 [c10];
  logic [3:0] v_c16 [c16];
  logic [3:0] v_c17 [c17];
  logic [3:0] v_c20 [c20];

  // ---- PACKAGE leaves, bare and qualified ------------------------------
  logic [3:0] v_pk_bare [PK_S];
  logic [3:0] v_pk_qual [pv89::PK_S];
  logic [3:0] v_pk_qu   [pv89::PK_U];
  logic [3:0] v_pk_by   [pv89::PK_BY];

  // ---- OVERRIDDEN sinks: default, literal actual, parameter actual -----
  va2_sink89                 u_def ();
  va2_sink89 #(.OVI(6))      u_lit ();
  va2_sink89 #(.OVI(c00))    u_ref ();

  // ---- a GENVAR read directly, and a genvar-derived localparam ---------
  for (genvar gk = 1; gk < 3; gk++) begin : gg
    logic [3:0] v_gv [gk];
    localparam int          gp_s = gk + 3;
    localparam int unsigned gp_u = gk + 3;
    logic [3:0] v_gp_s [gp_s];
    logic [3:0] v_gp_u [gp_u];
  end
endmodule

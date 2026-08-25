// r10earl89 g2 — THE `cts` HALF: where the sizing parameter's stored Value
// gets its SIGN from when the declared typespec is UNSIGNED.  GOLDEN = Surelog.
// Rows vary the INITIALIZER's own producer (bare ref to a signed / unsigned /
// untyped / byte / overridden / package parameter, two- and three-hop chains,
// a parenthesised ref, a cast, a ref inside an expression) and the OVERRIDE.
package q89;
  localparam int          PK_INT  = 4;
  localparam int unsigned PK_IU   = 4;
  localparam              PK_UN   = 4;
endpackage

module g2_sink89 #(parameter int OVI = 4, parameter int unsigned OVU = 4,
                   parameter NOV = 4) ();
  // an OVERRIDDEN `int` parameter used directly, and one hop below it
  logic [3:0] s_ovi      [OVI];
  localparam int          h_ovi   = OVI;        logic [3:0] s_h_ovi   [h_ovi];
  localparam int unsigned h_ovi_u = OVI;        logic [3:0] s_h_ovi_u [h_ovi_u];
  localparam int          h_nov   = NOV;        logic [3:0] s_h_nov   [h_nov];
  logic [3:0] s_ovu      [OVU];
  logic [3:0] s_nov      [NOV];
endmodule

module g2_89;
  import q89::*;
  localparam int          B_INT = 4;
  localparam int unsigned B_IU  = 4;
  localparam              B_UN  = 4;
  localparam byte         B_BY  = 4;
  localparam logic [7:0]  B_LG  = 4;
  localparam logic signed [7:0] B_LS = 4;

  // ---- ONE HOP: the declared type is UNSIGNED, the referenced one varies --
  localparam int unsigned r_iu_int = B_INT;  logic [3:0] v_r_iu_int [r_iu_int];
  localparam int unsigned r_iu_iu  = B_IU;   logic [3:0] v_r_iu_iu  [r_iu_iu];
  localparam int unsigned r_iu_un  = B_UN;   logic [3:0] v_r_iu_un  [r_iu_un];
  localparam int unsigned r_iu_by  = B_BY;   logic [3:0] v_r_iu_by  [r_iu_by];
  localparam int unsigned r_iu_lg  = B_LG;   logic [3:0] v_r_iu_lg  [r_iu_lg];
  localparam int unsigned r_iu_ls  = B_LS;   logic [3:0] v_r_iu_ls  [r_iu_ls];

  // ---- ONE HOP: the declared type is a NON-SWITCH kind -------------------
  localparam byte         r_by_int = B_INT;  logic [3:0] v_r_by_int [r_by_int];
  localparam byte         r_by_iu  = B_IU;   logic [3:0] v_r_by_iu  [r_by_iu];
  localparam integer      r_ig_int = B_INT;  logic [3:0] v_r_ig_int [r_ig_int];
  localparam integer      r_ig_iu  = B_IU;   logic [3:0] v_r_ig_iu  [r_ig_iu];

  // ---- ONE HOP: the declared type is UNTYPED (no typespec at all) --------
  localparam              r_un_int = B_INT;  logic [3:0] v_r_un_int [r_un_int];
  localparam              r_un_ls  = B_LS;   logic [3:0] v_r_un_ls  [r_un_ls];

  // ---- TWO and THREE HOPS -----------------------------------------------
  localparam int unsigned r2_a = r_iu_int;   logic [3:0] v_r2_a [r2_a];
  localparam int unsigned r3_a = r2_a;       logic [3:0] v_r3_a [r3_a];
  localparam int unsigned r2_b = r_iu_iu;    logic [3:0] v_r2_b [r2_b];
  localparam int unsigned r2_c = r_un_int;   logic [3:0] v_r2_c [r2_c];

  // ---- NOT a bare ref: parenthesised / cast / inside an expression -------
  localparam int unsigned p_par = (B_INT);       logic [3:0] v_p_par [p_par];
  localparam int unsigned p_cst = int'(B_INT);   logic [3:0] v_p_cst [p_cst];
  localparam int unsigned p_exp = B_INT + 0;     logic [3:0] v_p_exp [p_exp];
  localparam int unsigned p_uny = +B_INT;        logic [3:0] v_p_uny [p_uny];

  // ---- a PACKAGE member as the referenced parameter, BARE and QUALIFIED --
  localparam int unsigned k_bare = PK_INT;       logic [3:0] v_k_bare [k_bare];
  localparam int unsigned k_qual = q89::PK_INT;  logic [3:0] v_k_qual [k_qual];
  localparam int unsigned k_qiu  = q89::PK_IU;   logic [3:0] v_k_qiu  [k_qiu];
  localparam int unsigned k_qun  = q89::PK_UN;   logic [3:0] v_k_qun  [k_qun];
  // ...and the package member SIZING THE DIMENSION DIRECTLY
  logic [3:0] v_pk_bare [PK_INT];
  logic [3:0] v_pk_qual [q89::PK_INT];
  logic [3:0] v_pk_un   [PK_UN];

  // ---- the SIGNED declared types whose expression form is the head -------
  localparam int          e_int = B_INT + 1;     logic [3:0] v_e_int [e_int];
  localparam logic signed [7:0] e_ls = B_INT + 1; logic [3:0] v_e_ls [e_ls];
  localparam bit signed [7:0]   e_bs = B_INT + 1; logic [3:0] v_e_bs [e_bs];
  localparam signed [7:0]       e_sg = B_INT + 1; logic [3:0] v_e_sg [e_sg];

  // ---- OVERRIDE homes ----------------------------------------------------
  g2_sink89 #(.OVI(6), .OVU(6), .NOV(6))       u_lit ();
  g2_sink89 #(.OVI(B_INT), .OVU(B_INT), .NOV(B_INT)) u_ref ();
  g2_sink89                                     u_def ();
endmodule

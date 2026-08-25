// r10earl91 g2 — THE FIRST-OPERAND GRID.  Our stamp is a POSITION law ("a
// re-emitted OUTERMOST pattern sizes its FIRST operand at the element width").
// This arm varies WHAT SITS IN POSITION 0 and WHAT THE TARGET IS DECLARED AS,
// so the law's real predicate can be read off golden instead of guessed.
package q91;
  typedef struct packed { logic [11:0] q; } p_t;
  typedef struct packed { p_t prescale; logic [7:0] s; } c_t;
  typedef struct packed { c_t cfg0; logic ctrl; } r_t;
  typedef struct packed { logic [11:0] a; logic [7:0] b; } st_t;
endpackage

module g2_first91 (input logic clk, input logic [11:0] din, output logic [63:0] o);
  import q91::*;
  r_t  reg2hw;
  logic [11:0] v12;
  logic [11:0] arr12 [2];

  // ---- UNPACKED ARRAY [1] of 12 bits, first operand varies ------------
  logic [11:0] u_hp  [1];  assign u_hp  = '{reg2hw.cfg0.prescale.q};   // hier_path
  logic [11:0] u_ref [1];  assign u_ref = '{v12};                      // ref_obj
  logic [11:0] u_con [1];  assign u_con = '{12'd5};                    // constant
  logic [11:0] u_bar [1];  assign u_bar = '{5};                        // bare decimal
  logic [11:0] u_bs  [1];  assign u_bs  = '{arr12[0]};                 // bit/var select
  logic [11:0] u_ps  [1];  assign u_ps  = '{din[7:0]};                 // part_select
  logic [11:0] u_op  [1];  assign u_op  = '{v12 + 12'd1};              // operation
  logic [11:0] u_cst [1];  assign u_cst = '{12'(reg2hw.cfg0.prescale.q)}; // cast

  // ---- UNPACKED ARRAY [2]: hier_path FIRST, hier_path SECOND ----------
  logic [11:0] u2 [2];
  assign u2 = '{reg2hw.cfg0.prescale.q, reg2hw.cfg0.prescale.q};
  logic [11:0] u2b [2];
  assign u2b = '{12'd3, reg2hw.cfg0.prescale.q};

  // ---- PACKED VECTOR target ------------------------------------------
  logic [1:0] pk_hp;   assign pk_hp  = '{reg2hw.cfg0.prescale.q[0], 1'b0};
  logic [1:0] pk_con;  assign pk_con = '{1'b1, 1'b0};

  // ---- PACKED ARRAY target -------------------------------------------
  logic [1:0][11:0] pa_hp;  assign pa_hp = '{reg2hw.cfg0.prescale.q, 12'd1};

  // ---- STRUCT target (the flatten path) -------------------------------
  st_t s_hp;  assign s_hp = '{reg2hw.cfg0.prescale.q, reg2hw.cfg0.s};
  st_t s_con; assign s_con = '{12'd9, 8'd3};

  // ---- UNPACKED ARRAY OF STRUCT ---------------------------------------
  st_t sa [1]; assign sa = '{'{reg2hw.cfg0.prescale.q, reg2hw.cfg0.s}};

  assign o = {8'd0, u_hp[0], u_ref[0], u_con[0], u_bar[0]} ^
             {8'd0, u_bs[0], u_ps[0], u_op[0], u_cst[0]} ^
             {8'd0, u2[0], u2[1], u2b[0], u2b[1]} ^
             {30'd0, pk_hp, pk_con, pa_hp[0], pa_hp[1]} ^
             {24'd0, s_hp.a, s_hp.b, s_con.a, s_con.b} ^
             {44'd0, sa[0].a, sa[0].b};
endmodule

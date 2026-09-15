// r11u35 g3_shape35 — THE BOUND SHAPE, at the site § typeParamAnonAggMemberNoReduce35
// owns.  One anonymous-struct member per written bound form, so the law's
// "keep what was written" is read per shape and not per site.
package g3pk35;
  parameter int unsigned PW = 12;
  typedef struct packed { int unsigned W; int unsigned D; } cfg_t;
  localparam cfg_t CFG = '{W: 32'd48, D: 32'd16};
endpackage

module g3sub35 #(
    parameter int unsigned NU  = 5,
    parameter int          NS  = 6,
    parameter              NX  = 7,
    parameter byte         NB  = 9,
    parameter g3pk35::cfg_t Cfg = g3pk35::CFG
) ();
  localparam int unsigned LU = NU + 2;

  localparam type sh_t = struct packed {
    logic [NU-1:0]          a_sub;      // param ref minus one
    logic [NU:0]            b_bare;     // a BARE NAME
    logic [7:0]             c_lit;      // a LITERAL (must not move)
    logic [8'd7:0]          d_sized;    // a SIZED literal (must not move)
    logic [NU+1:0]          e_add;      // an ADD
    logic [1+NU:0]          f_add2;     // an ADD the other way round
    logic [NU+8'd2:0]       g_addsz;    // an ADD with a based-decimal operand
    logic [NU*2-1:0]        h_mul;      // a MULTIPLY inside a subtract
    logic [(NU*2)-1:0]      i_paren;    // ...parenthesised
    logic [NU/1:0]          j_div;      // a DIVIDE
    logic [NU<<1:0]         k_shl;      // a SHIFT
    logic [$clog2(NU)-1:0]  l_clog;     // a SYSTEM CALL
    logic [LU-1:0]          m_local;    // a LOCALPARAM read
    logic [NS-1:0]          n_signed;   // a SIGNED int parameter
    logic [NX-1:0]          o_untyped;  // an UNTYPED parameter
    logic [NB-1:0]          p_byte;     // a BYTE parameter
    logic [Cfg.W-1:0]       q_hier;     // a struct-param MEMBER read
    logic [Cfg.D:0]         r_hierbare; // ...bare
    logic [g3pk35::PW-1:0]  s_pkgq;     // a QUALIFIED package parameter
    logic [NU-1:0][1:0]     t_2d;       // two packed dims
    logic signed [NU-1:0]   u_sgn;      // a SIGNED member
  };
  sh_t sv;

  // Two declarators on one `localparam type` keyword.
  localparam type v_t = struct packed { logic [NU-1:0] a; },
                  w_t = struct packed { logic [NU+1:0] a; };
  v_t vv;
  w_t wv;
endmodule

module g3_shape35 ();
  g3sub35 #() u_def ();
  g3sub35 #(.NU(9)) u_ov ();
endmodule

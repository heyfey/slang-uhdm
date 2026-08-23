// r10vearl74 adversarial grid B — every range-bound SHAPE the verification
// brief names, crossed with the operator that produced the parameter's value,
// the home, and the instance count.  MEASUREMENT ONLY.
package vpb74;
  parameter  int QP  = 8;        // literal      -> UINT
  localparam int QM  = 4 * 2;    // multiply     -> INT
  localparam int QA  = 4 + 4;    // add          -> UINT
  localparam int QS  = 12 - 4;   // subtract     -> INT
  localparam int QD  = 32 / 4;   // divide       -> INT
  localparam int QL  = 1 << 3;   // shift left   -> UINT
  localparam int QR  = 64 >> 3;  // shift right  -> UINT
  localparam int QC  = $clog2(256); // clog2     -> UINT
  localparam int QB  = 8'h08;    // based literal
  localparam int QT  = int'(16 / 2); // cast
  localparam     QU  = 4 * 2;    // untyped multiply
endpackage

// ---------- the SINK: every shape, sized off ONE instance parameter --------
module vsnk74 #(
  parameter int D = 4,
  parameter int E = 2
) (
  input  logic [3:0] p_sz  [D],        // PORT, size form
  input  logic [D-1:0] p_pk,           // PORT, packed ranged
  output logic [3:0] p_z   [0:D-1]     // PORT, 0:D-1
);
  logic [3:0]      s_sz   [D];         // array_var, size form
  logic [3:0]      s_rg   [D-1:0];     // array_var, D-1:0
  logic [3:0]      s_z    [0:D-1];     // array_var, 0:D-1
  logic [3:0]      s_dbl  [D*2];       // size form over an EXPRESSION
  logic [3:0]      s_2d   [D][E];      // TWO size-form dims
  logic [D-1:0]    s_pk;               // PACKED ranged
  logic [$clog2(D)-1:0] s_cpk;         // PACKED, $clog2 bound
  logic [D:D+3]    s_updn;             // packed, both bounds from D
  wire  [3:0]      s_net  [D];         // array_net, size form
  wire  [D-1:0]    s_pknet;            // packed net
  typedef logic [3:0] s_td_t [D];      // typedef'd unpacked array typespec
  s_td_t           s_td;
  typedef logic [D-1:0] s_tp_t;        // typedef'd packed typespec
  s_tp_t           s_tp;
  logic [3:0]      s_ps   [D];
  logic [3:0]      s_slice;
  assign s_slice = s_ps[D-2];          // part-select style index off D
endmodule

// ---------- driver: 11 override actuals, 1..3 instances --------------------
module vovr74 ();
  localparam int A = 8;
  logic [3:0] w8 [8];
  logic [7:0] q8;
  logic [3:0] z8 [0:7];
  vsnk74 #(.D(4 * 2),        .E(2)) u_mul  (.p_sz(w8), .p_pk(q8), .p_z(z8));
  vsnk74 #(.D(16 / 2),       .E(2)) u_div  (.p_sz(w8), .p_pk(q8), .p_z(z8));
  vsnk74 #(.D(12 - 4),       .E(2)) u_sub  (.p_sz(w8), .p_pk(q8), .p_z(z8));
  vsnk74 #(.D(4 + 4),        .E(2)) u_add  (.p_sz(w8), .p_pk(q8), .p_z(z8));
  vsnk74 #(.D(1 << 3),       .E(2)) u_shl  (.p_sz(w8), .p_pk(q8), .p_z(z8));
  vsnk74 #(.D(64 >> 3),      .E(2)) u_shr  (.p_sz(w8), .p_pk(q8), .p_z(z8));
  vsnk74 #(.D($clog2(256)),  .E(2)) u_clog (.p_sz(w8), .p_pk(q8), .p_z(z8));
  vsnk74 #(.D(A),            .E(2)) u_ref  (.p_sz(w8), .p_pk(q8), .p_z(z8));
  vsnk74 #(.D(8),            .E(2)) u_lit  (.p_sz(w8), .p_pk(q8), .p_z(z8));
  vsnk74 #(.D(8'h08),        .E(2)) u_bas  (.p_sz(w8), .p_pk(q8), .p_z(z8));
  vsnk74 #(.D(int'(16 / 2)), .E(2)) u_cst  (.p_sz(w8), .p_pk(q8), .p_z(z8));
  vsnk74 #(.D(vpb74::QM),    .E(2)) u_pqm  (.p_sz(w8), .p_pk(q8), .p_z(z8));
  vsnk74 #(.D(vpb74::QA),    .E(2)) u_pqa  (.p_sz(w8), .p_pk(q8), .p_z(z8));
  vsnk74 #(.D(vpb74::QU),    .E(2)) u_pqu  (.p_sz(w8), .p_pk(q8), .p_z(z8));
  // THREE instances of ONE specialization, and an INSTANCE ARRAY
  vsnk74 #(.D(4 * 2),        .E(2)) u_m2   (.p_sz(w8), .p_pk(q8), .p_z(z8));
  vsnk74 #(.D(4 * 2),        .E(2)) u_m3   (.p_sz(w8), .p_pk(q8), .p_z(z8));
  vsnk74 #(.D(4 * 2),        .E(2)) u_arr [0:2] (.p_sz(w8), .p_pk(q8), .p_z(z8));
endmodule

// ---------- homes: gen-for, gen-if, nested gen ----------------------------
module vhome74 ();
  localparam int A = 4;
  localparam int B = 2;
  localparam int HM = A * B;   // INT, 8
  localparam int HA = A + B;   // UINT, 6
  logic [3:0] wh [8];
  logic [7:0] qh;
  logic [3:0] zh [0:7];
  logic [3:0] h_m_sz [HM];
  logic [HM-1:0] h_m_pk;
  logic [3:0] h_a_sz [HA];
  for (genvar gi = 0; gi < 2; gi++) begin : gfor
    localparam int GM = A * B;
    localparam int GA = A + B;
    localparam int GV = (gi + 1) * 4;
    logic [3:0]   g_m_sz [GM];
    logic [3:0]   g_a_sz [GA];
    logic [3:0]   g_v_sz [GV];
    logic [GM-1:0] g_m_pk;
    logic [3:0]   g_m_dbl [GM*2];
    wire  [3:0]   g_m_net [GM];
    vsnk74 #(.D(GM), .E(2)) u_g (.p_sz(wh), .p_pk(qh), .p_z(zh));
    if (gi == 0) begin : gif
      localparam int IM = A * B;
      localparam int IA = A + B;
      logic [3:0] i_m_sz [IM];
      logic [3:0] i_a_sz [IA];
      logic [IM-1:0] i_m_pk;
    end
    for (genvar gj = 0; gj < 2; gj++) begin : gnest
      localparam int NM = A * B;
      localparam int NA = A + B;
      logic [3:0] n_m_sz [NM];
      logic [3:0] n_a_sz [NA];
      logic [NM-1:0] n_m_pk;
    end
  end
endmodule

// ---------- interface and program homes -----------------------------------
interface vifc74 #(parameter int D = 8) ();
  localparam int IM = D * 2;
  localparam int IA = D + 2;
  logic [3:0]   f_m_sz [IM];
  logic [3:0]   f_a_sz [IA];
  logic [IM-1:0] f_m_pk;
  logic [3:0]   f_d_sz [D];
  wire  [3:0]   f_net  [D];
endinterface

program vprg74 #(parameter int D = 8) ();
  localparam int PM2 = D * 2;
  localparam int PA2 = D + 2;
  logic [3:0]   r_m_sz [PM2];
  logic [3:0]   r_a_sz [PA2];
  logic [PM2-1:0] r_m_pk;
  logic [3:0]   r_d_sz [D];
endprogram

module vifhome74 ();
  localparam int A = 16;
  localparam int B = 2;
  vifc74 #(.D(A / B)) u_if_div ();
  vifc74 #(.D(A + B)) u_if_add ();
  vprg74 #(.D(A / B)) u_pr_div ();
endmodule

// ---------- 2 and 3 hop derivation chains ---------------------------------
module vlf74 #(parameter int D = 4) ();
  logic [3:0] l_sz [D];
  logic [D-1:0] l_pk;
  logic [3:0] l_dbl [D*2];
endmodule

module vm274 #(parameter int MD = 4) ();
  localparam int M2 = MD * 2;
  localparam int M2A = MD + 2;
  logic [3:0] m_sz [MD];
  logic [3:0] m_m2 [M2];
  logic [3:0] m_a2 [M2A];
  vlf74 #(.D(MD))  u_l1 ();
  vlf74 #(.D(M2))  u_l2 ();
  vlf74 #(.D(M2A)) u_l3 ();
endmodule

module vch74 ();
  localparam int A = 16;
  localparam int B = 2;
  localparam int CM = A * B;   // INT
  localparam int CA = A + B;   // UINT
  vm274 #(.MD(CM)) u_cm ();
  vm274 #(.MD(CA)) u_ca ();
  vm274 #(.MD(8))  u_cl ();
endmodule

// ---------- negative and 64-bit -------------------------------------------
module vneg74 ();
  localparam int NEG  = 2 - 6;       // -4, INT
  localparam int NEGA = (0 - 2) + (0 - 2); // -4, UINT
  localparam longint W64 = 64'd8;
  localparam longint W64M = 4 * 2;
  logic [NEG:1]   n_pk;              // packed range with a NEGATIVE left bound
  logic [NEGA:1]  n_pka;
  logic [3:0]     n_w64 [W64];       // 64-bit-typed size
  logic [3:0]     n_w64m [W64M];
  logic [W64-1:0] n_w64_pk;
endmodule

module vtopb74 ();
  vovr74    u_ovr ();
  vhome74   u_home ();
  vifhome74 u_ifh ();
  vch74     u_ch ();
  vneg74    u_neg ();
endmodule

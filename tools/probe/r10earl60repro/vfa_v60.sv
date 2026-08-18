// v60 VERIFIER arm A — the package-member TYPE grid the implementer's v60e
// left open: UNTYPED members, signed, the small integer types, real, string,
// time, a typedef'd vector, an enum, a packed struct reached WITHOUT an
// aggregate literal, and a 2-D packed vector.  Every module localparam is
// TYPED (the arm's outer gate) and the package is NOT imported.
package tp;
  localparam                UA   = 8;             // UNTYPED (implicit int)
  localparam        [11:0]  UB   = 12'h380;       // UNTYPED but RANGED
  localparam signed [7:0]   US   = -3;            // UNTYPED, signed+ranged
  localparam int signed     SI   = -5;
  localparam int unsigned   UI   = 5;
  localparam byte           BY   = 8'sh7;
  localparam shortint       SH   = 12;
  localparam longint        LO   = 64'd13;
  localparam integer        IG   = 14;
  localparam bit            BT   = 1'b1;
  localparam logic          LG   = 1'b0;
  localparam real           RE   = 1.5;
  localparam string         ST   = "abc";
  localparam time           TM   = 10ns;
  typedef logic [7:0] v_t;
  localparam v_t            TV   = 8'hA5;
  typedef enum logic [1:0] { E0, E1, E2 } e_t;
  localparam e_t            EV   = E1;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  localparam s_t            SV   = 8'h12;         // NOT an aggregate literal
  localparam logic [1:0][3:0] MD = 8'h34;         // 2-D packed
endpackage

module s_a ();
  localparam int              a_ua = tp::UA;
  localparam logic [11:0]     a_ub = tp::UB;
  localparam logic signed [7:0] a_us = tp::US;
  localparam int signed       a_si = tp::SI;
  localparam int unsigned     a_ui = tp::UI;
  localparam byte             a_by = tp::BY;
  localparam shortint         a_sh = tp::SH;
  localparam longint          a_lo = tp::LO;
  localparam integer          a_ig = tp::IG;
  localparam bit              a_bt = tp::BT;
  localparam logic            a_lg = tp::LG;
  localparam real             a_re = tp::RE;
  localparam string           a_st = tp::ST;
  localparam time             a_tm = tp::TM;
  localparam tp::v_t          a_tv = tp::TV;
  localparam logic [7:0]      a_tv2 = tp::TV;     // typedef member, PLAIN type
  localparam tp::e_t          a_ev = tp::EV;
  localparam tp::s_t          a_sv = tp::SV;
  localparam logic [1:0][3:0] a_md = tp::MD;
  logic [a_ua-1:0] d;
endmodule

module a1 ();
  s_a u_a ();
endmodule

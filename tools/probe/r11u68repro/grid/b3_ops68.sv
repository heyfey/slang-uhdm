// r11u68 arm b3 — THE OPERATOR and UNKNOWN/WIDTH faces of the refusal set,
// same bail detector as b1/b2 (controls at 8 = walk completed, 64 = bailed).
package qd;
  localparam int K = 6;
  localparam int unsigned KU = 6;
  typedef struct packed {
    logic [7:0] p;
    logic [7:0] c1;
    logic [7:0] c2;
  } dt_t;
  localparam dt_t N_plain = '{p: 3, c1: K + 1, c2: K + 1};  // NO-BAIL POSITIVE CONTROL
  localparam dt_t N_xor = '{p: KU ^ 3, c1: K + 1, c2: K + 1};  // ^
  localparam dt_t N_xnor1 = '{p: KU ~^ 3, c1: K + 1, c2: K + 1};  // ~^
  localparam dt_t N_xnor2 = '{p: KU ^~ 3, c1: K + 1, c2: K + 1};  // ^~
  localparam dt_t N_rand = '{p: &KU, c1: K + 1, c2: K + 1};  // reduction &
  localparam dt_t N_ror = '{p: |KU, c1: K + 1, c2: K + 1};  // reduction |
  localparam dt_t N_rxor = '{p: ^KU, c1: K + 1, c2: K + 1};  // reduction ^
  localparam dt_t N_rnand = '{p: ~&KU, c1: K + 1, c2: K + 1};  // reduction ~&
  localparam dt_t N_rnor = '{p: ~|KU, c1: K + 1, c2: K + 1};  // reduction ~|
  localparam dt_t N_rxnor = '{p: ~^KU, c1: K + 1, c2: K + 1};  // reduction ~^
  localparam dt_t N_land = '{p: K && 1, c1: K + 1, c2: K + 1};  // &&
  localparam dt_t N_lor = '{p: K || 0, c1: K + 1, c2: K + 1};  // ||
  localparam dt_t N_lnot = '{p: !K, c1: K + 1, c2: K + 1};  // !
  localparam dt_t N_bnot = '{p: ~KU, c1: K + 1, c2: K + 1};  // ~
  localparam dt_t N_eqq = '{p: K == 6, c1: K + 1, c2: K + 1};  // ==
  localparam dt_t N_nee = '{p: K != 6, c1: K + 1, c2: K + 1};  // !=
  localparam dt_t N_gee = '{p: K >= 6, c1: K + 1, c2: K + 1};  // >=
  localparam dt_t N_lee = '{p: K <= 6, c1: K + 1, c2: K + 1};  // <=
  localparam dt_t N_lt = '{p: K < 9, c1: K + 1, c2: K + 1};  // <
  localparam dt_t N_ceq = '{p: K === 6, c1: K + 1, c2: K + 1};  // ===
  localparam dt_t N_cne = '{p: K !== 6, c1: K + 1, c2: K + 1};  // !==
  localparam dt_t N_wieq = '{p: K ==? 6, c1: K + 1, c2: K + 1};  // ==?
  localparam dt_t N_shl = '{p: KU << 1, c1: K + 1, c2: K + 1};  // <<
  localparam dt_t N_ashl = '{p: K <<< 1, c1: K + 1, c2: K + 1};  // <<<
  localparam dt_t N_ashr = '{p: K >>> 1, c1: K + 1, c2: K + 1};  // >>>
  localparam dt_t N_uplus = '{p: +K, c1: K + 1, c2: K + 1};  // unary +
  localparam dt_t N_pow = '{p: K ** 2, c1: K + 1, c2: K + 1};  // **
  localparam dt_t N_xunsz = '{p: 'x, c1: K + 1, c2: K + 1};  // an UNBASED-UNSIZED x
  localparam dt_t N_zunsz = '{p: 'z, c1: K + 1, c2: K + 1};  // an UNBASED-UNSIZED z
  localparam dt_t N_ounsz = '{p: '0, c1: K + 1, c2: K + 1};  // an UNBASED-UNSIZED 0
  localparam dt_t N_xmid = '{p: 8'b1x000001, c1: K + 1, c2: K + 1};  // an unknown in bit 6
  localparam dt_t N_xhex = '{p: 8'hX, c1: K + 1, c2: K + 1};  // an all-unknown HEX literal
  localparam dt_t N_xoct = '{p: 8'oX, c1: K + 1, c2: K + 1};  // an all-unknown OCT literal
  localparam dt_t N_xdec = '{p: 8'dX, c1: K + 1, c2: K + 1};  // an all-unknown DEC literal
  localparam dt_t N_o96 = '{p: 96'o1, c1: K + 1, c2: K + 1};  // a >64-bit OCT literal
  localparam dt_t N_d96 = '{p: 96'h1, c1: K + 1, c2: K + 1};  // a >64-bit HEX literal, tiny value
  localparam dt_t N_b70 = '{p: 70'b1010, c1: K + 1, c2: K + 1};  // a 70-bit BIN literal
  localparam dt_t N_h70 = '{p: 70'h5, c1: K + 1, c2: K + 1};  // a 70-bit HEX literal
  localparam dt_t N_h64 = '{p: 64'hFFFFFFFFFFFFFFFF, c1: K + 1, c2: K + 1};  // a 64-bit HEX literal
  localparam dt_t N_h65 = '{p: 65'h1, c1: K + 1, c2: K + 1};  // a 65-bit HEX literal
endpackage
module b3_ops68 #(parameter qd::dt_t C_plain = qd::N_plain,
                parameter qd::dt_t C_xor = qd::N_xor,
                parameter qd::dt_t C_xnor1 = qd::N_xnor1,
                parameter qd::dt_t C_xnor2 = qd::N_xnor2,
                parameter qd::dt_t C_rand = qd::N_rand,
                parameter qd::dt_t C_ror = qd::N_ror,
                parameter qd::dt_t C_rxor = qd::N_rxor,
                parameter qd::dt_t C_rnand = qd::N_rnand,
                parameter qd::dt_t C_rnor = qd::N_rnor,
                parameter qd::dt_t C_rxnor = qd::N_rxnor,
                parameter qd::dt_t C_land = qd::N_land,
                parameter qd::dt_t C_lor = qd::N_lor,
                parameter qd::dt_t C_lnot = qd::N_lnot,
                parameter qd::dt_t C_bnot = qd::N_bnot,
                parameter qd::dt_t C_eqq = qd::N_eqq,
                parameter qd::dt_t C_nee = qd::N_nee,
                parameter qd::dt_t C_gee = qd::N_gee,
                parameter qd::dt_t C_lee = qd::N_lee,
                parameter qd::dt_t C_lt = qd::N_lt,
                parameter qd::dt_t C_ceq = qd::N_ceq,
                parameter qd::dt_t C_cne = qd::N_cne,
                parameter qd::dt_t C_wieq = qd::N_wieq,
                parameter qd::dt_t C_shl = qd::N_shl,
                parameter qd::dt_t C_ashl = qd::N_ashl,
                parameter qd::dt_t C_ashr = qd::N_ashr,
                parameter qd::dt_t C_uplus = qd::N_uplus,
                parameter qd::dt_t C_pow = qd::N_pow,
                parameter qd::dt_t C_xunsz = qd::N_xunsz,
                parameter qd::dt_t C_zunsz = qd::N_zunsz,
                parameter qd::dt_t C_ounsz = qd::N_ounsz,
                parameter qd::dt_t C_xmid = qd::N_xmid,
                parameter qd::dt_t C_xhex = qd::N_xhex,
                parameter qd::dt_t C_xoct = qd::N_xoct,
                parameter qd::dt_t C_xdec = qd::N_xdec,
                parameter qd::dt_t C_o96 = qd::N_o96,
                parameter qd::dt_t C_d96 = qd::N_d96,
                parameter qd::dt_t C_b70 = qd::N_b70,
                parameter qd::dt_t C_h70 = qd::N_h70,
                parameter qd::dt_t C_h64 = qd::N_h64,
                parameter qd::dt_t C_h65 = qd::N_h65)
                (output logic [31:0] y_plain,
                 output logic [31:0] y_xor,
                 output logic [31:0] y_xnor1,
                 output logic [31:0] y_xnor2,
                 output logic [31:0] y_rand,
                 output logic [31:0] y_ror,
                 output logic [31:0] y_rxor,
                 output logic [31:0] y_rnand,
                 output logic [31:0] y_rnor,
                 output logic [31:0] y_rxnor,
                 output logic [31:0] y_land,
                 output logic [31:0] y_lor,
                 output logic [31:0] y_lnot,
                 output logic [31:0] y_bnot,
                 output logic [31:0] y_eqq,
                 output logic [31:0] y_nee,
                 output logic [31:0] y_gee,
                 output logic [31:0] y_lee,
                 output logic [31:0] y_lt,
                 output logic [31:0] y_ceq,
                 output logic [31:0] y_cne,
                 output logic [31:0] y_wieq,
                 output logic [31:0] y_shl,
                 output logic [31:0] y_ashl,
                 output logic [31:0] y_ashr,
                 output logic [31:0] y_uplus,
                 output logic [31:0] y_pow,
                 output logic [31:0] y_xunsz,
                 output logic [31:0] y_zunsz,
                 output logic [31:0] y_ounsz,
                 output logic [31:0] y_xmid,
                 output logic [31:0] y_xhex,
                 output logic [31:0] y_xoct,
                 output logic [31:0] y_xdec,
                 output logic [31:0] y_o96,
                 output logic [31:0] y_d96,
                 output logic [31:0] y_b70,
                 output logic [31:0] y_h70,
                 output logic [31:0] y_h64,
                 output logic [31:0] y_h65);
  assign y_plain = {C_plain.p, C_plain.c1, C_plain.c2};
  assign y_xor = {C_xor.p, C_xor.c1, C_xor.c2};
  assign y_xnor1 = {C_xnor1.p, C_xnor1.c1, C_xnor1.c2};
  assign y_xnor2 = {C_xnor2.p, C_xnor2.c1, C_xnor2.c2};
  assign y_rand = {C_rand.p, C_rand.c1, C_rand.c2};
  assign y_ror = {C_ror.p, C_ror.c1, C_ror.c2};
  assign y_rxor = {C_rxor.p, C_rxor.c1, C_rxor.c2};
  assign y_rnand = {C_rnand.p, C_rnand.c1, C_rnand.c2};
  assign y_rnor = {C_rnor.p, C_rnor.c1, C_rnor.c2};
  assign y_rxnor = {C_rxnor.p, C_rxnor.c1, C_rxnor.c2};
  assign y_land = {C_land.p, C_land.c1, C_land.c2};
  assign y_lor = {C_lor.p, C_lor.c1, C_lor.c2};
  assign y_lnot = {C_lnot.p, C_lnot.c1, C_lnot.c2};
  assign y_bnot = {C_bnot.p, C_bnot.c1, C_bnot.c2};
  assign y_eqq = {C_eqq.p, C_eqq.c1, C_eqq.c2};
  assign y_nee = {C_nee.p, C_nee.c1, C_nee.c2};
  assign y_gee = {C_gee.p, C_gee.c1, C_gee.c2};
  assign y_lee = {C_lee.p, C_lee.c1, C_lee.c2};
  assign y_lt = {C_lt.p, C_lt.c1, C_lt.c2};
  assign y_ceq = {C_ceq.p, C_ceq.c1, C_ceq.c2};
  assign y_cne = {C_cne.p, C_cne.c1, C_cne.c2};
  assign y_wieq = {C_wieq.p, C_wieq.c1, C_wieq.c2};
  assign y_shl = {C_shl.p, C_shl.c1, C_shl.c2};
  assign y_ashl = {C_ashl.p, C_ashl.c1, C_ashl.c2};
  assign y_ashr = {C_ashr.p, C_ashr.c1, C_ashr.c2};
  assign y_uplus = {C_uplus.p, C_uplus.c1, C_uplus.c2};
  assign y_pow = {C_pow.p, C_pow.c1, C_pow.c2};
  assign y_xunsz = {C_xunsz.p, C_xunsz.c1, C_xunsz.c2};
  assign y_zunsz = {C_zunsz.p, C_zunsz.c1, C_zunsz.c2};
  assign y_ounsz = {C_ounsz.p, C_ounsz.c1, C_ounsz.c2};
  assign y_xmid = {C_xmid.p, C_xmid.c1, C_xmid.c2};
  assign y_xhex = {C_xhex.p, C_xhex.c1, C_xhex.c2};
  assign y_xoct = {C_xoct.p, C_xoct.c1, C_xoct.c2};
  assign y_xdec = {C_xdec.p, C_xdec.c1, C_xdec.c2};
  assign y_o96 = {C_o96.p, C_o96.c1, C_o96.c2};
  assign y_d96 = {C_d96.p, C_d96.c1, C_d96.c2};
  assign y_b70 = {C_b70.p, C_b70.c1, C_b70.c2};
  assign y_h70 = {C_h70.p, C_h70.c1, C_h70.c2};
  assign y_h64 = {C_h64.p, C_h64.c1, C_h64.c2};
  assign y_h65 = {C_h65.p, C_h65.c1, C_h65.c2};
endmodule

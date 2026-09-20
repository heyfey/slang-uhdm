// v11u68 ADVERSARIAL arm v1 — LAW A OVER-FIRE HUNT.  Operand 0 is the
// candidate; operands 1 and 2 are the control `K + 1` (reduce size 64) on
// 8-bit members.  golden ctl 8 = the walk COMPLETED, ctl 64 = it BAILED.
// A cell where golden reads 8 and the LAW binary reads 64 is a MOVED-WRONG.
package qq;
  localparam int K = 6;
  localparam int unsigned KU = 6;
  localparam int PK = 11;
  localparam logic [95:0] PW = 96'd12;
  localparam logic [15:0] VEC = 16'd3;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } inner_t;
  function automatic int f_add(int x, int y); return x + y; endfunction
  function automatic logic [7:0] f_vec(int x); return x[7:0]; endfunction
  typedef struct packed {
    logic [31:0] p;   // the candidate
    logic [7:0] c1;   // K + 1   -- control
    logic [7:0] c2;   // K + 1   -- control
  } vt_t;
  typedef struct packed {
    inner_t p;
    logic [7:0] c1;
    logic [7:0] c2;
  } vn_t;
  localparam vt_t L_plain = '{p: 3, c1: K + 1, c2: K + 1};  // NO-BAIL POSITIVE CONTROL
  localparam vt_t L_pkgref = '{p: qq::PK, c1: K + 1, c2: K + 1};  // a package-qualified param ref
  localparam vt_t L_pkgparm = '{p: qq::PW, c1: K + 1, c2: K + 1};  // a package param of 96 bits
  localparam vt_t L_sysbits = '{p: $bits(int), c1: K + 1, c2: K + 1};  // $bits
  localparam vt_t L_syshigh = '{p: $high(qq::VEC), c1: K + 1, c2: K + 1};  // $high of a packed vector
  localparam vt_t L_fcall2 = '{p: f_add(2,3), c1: K + 1, c2: K + 1};  // a 2-arg constant function call
  localparam vt_t L_fcallv = '{p: f_vec(3), c1: K + 1, c2: K + 1};  // a function returning logic[7:0]
  localparam vt_t L_negl1 = '{p: -1, c1: K + 1, c2: K + 1};  // unary minus over a literal
  localparam vt_t L_shl2 = '{p: K << 2, c1: K + 1, c2: K + 1};  // a left shift
  localparam vt_t L_shlu = '{p: KU <<< 2, c1: K + 1, c2: K + 1};  // an arithmetic left shift
  localparam vt_t L_sgnhex = '{p: 8'shF0, c1: K + 1, c2: K + 1};  // a SIGNED hex literal, msb set
  localparam vt_t L_sgnbin = '{p: 4'sb1011, c1: K + 1, c2: K + 1};  // a SIGNED bin literal, msb set
  localparam vt_t L_sgndec = '{p: 8'sd200, c1: K + 1, c2: K + 1};  // a SIGNED dec literal that overflows
  localparam vt_t L_strl9 = '{p: "abcdefghi", c1: K + 1, c2: K + 1};  // a 9-char string literal
  localparam vt_t L_unkz = '{p: 1'bz, c1: K + 1, c2: K + 1};  // a high-Z bit
  localparam vt_t L_unkhx = '{p: 8'hxA, c1: K + 1, c2: K + 1};  // a hex with a LEADING unknown
  localparam vt_t L_unkhx2 = '{p: 8'hAx, c1: K + 1, c2: K + 1};  // a hex with a TRAILING unknown
  localparam vt_t L_unkox = '{p: 6'ox7, c1: K + 1, c2: K + 1};  // an oct with a LEADING unknown
  localparam vt_t L_wide70 = '{p: 70'h5, c1: K + 1, c2: K + 1};  // a 70-bit hex literal
  localparam vt_t L_wide96 = '{p: 96'b1, c1: K + 1, c2: K + 1};  // a 96-bit bin literal
  localparam vt_t L_wide65d = '{p: 65'd1, c1: K + 1, c2: K + 1};  // a 65-bit dec literal
  localparam vt_t L_bigdec = '{p: 64'd18446744073709551615, c1: K + 1, c2: K + 1};  // a 64-bit all-ones decimal
  localparam vt_t L_xorn = '{p: KU ^ 3, c1: K + 1, c2: K + 1};  // the XOR (KNOWN BAIL control)
  localparam vt_t L_negk = '{p: -K, c1: K + 1, c2: K + 1};  // a negative (KNOWN BAIL control)
  localparam vt_t L_tcast = '{p: byte'(7), c1: K + 1, c2: K + 1};  // a named-type cast (KNOWN BAIL control)
  localparam vt_t L_eqq = '{p: K === 6, c1: K + 1, c2: K + 1};  // a case-equality (KNOWN BAIL control)
  localparam vn_t L_nested = '{p: '{a: 8'd1, b: 8'd2}, c1: K + 1, c2: K + 1};  // a NESTED struct pattern (KNOWN BAIL)
  localparam vt_t L_uplus = '{p: +K, c1: K + 1, c2: K + 1};  // a unary plus (KNOWN BAIL control)
endpackage
module v1_ofire68 #(parameter qq::vt_t C_plain = qq::L_plain,
                parameter qq::vt_t C_pkgref = qq::L_pkgref,
                parameter qq::vt_t C_pkgparm = qq::L_pkgparm,
                parameter qq::vt_t C_sysbits = qq::L_sysbits,
                parameter qq::vt_t C_syshigh = qq::L_syshigh,
                parameter qq::vt_t C_fcall2 = qq::L_fcall2,
                parameter qq::vt_t C_fcallv = qq::L_fcallv,
                parameter qq::vt_t C_negl1 = qq::L_negl1,
                parameter qq::vt_t C_shl2 = qq::L_shl2,
                parameter qq::vt_t C_shlu = qq::L_shlu,
                parameter qq::vt_t C_sgnhex = qq::L_sgnhex,
                parameter qq::vt_t C_sgnbin = qq::L_sgnbin,
                parameter qq::vt_t C_sgndec = qq::L_sgndec,
                parameter qq::vt_t C_strl9 = qq::L_strl9,
                parameter qq::vt_t C_unkz = qq::L_unkz,
                parameter qq::vt_t C_unkhx = qq::L_unkhx,
                parameter qq::vt_t C_unkhx2 = qq::L_unkhx2,
                parameter qq::vt_t C_unkox = qq::L_unkox,
                parameter qq::vt_t C_wide70 = qq::L_wide70,
                parameter qq::vt_t C_wide96 = qq::L_wide96,
                parameter qq::vt_t C_wide65d = qq::L_wide65d,
                parameter qq::vt_t C_bigdec = qq::L_bigdec,
                parameter qq::vt_t C_xorn = qq::L_xorn,
                parameter qq::vt_t C_negk = qq::L_negk,
                parameter qq::vt_t C_tcast = qq::L_tcast,
                parameter qq::vt_t C_eqq = qq::L_eqq,
                parameter qq::vn_t C_nested = qq::L_nested,
                parameter qq::vt_t C_uplus = qq::L_uplus)
           (output logic [7:0] o_plain, output logic [7:0] o_pkgref, output logic [7:0] o_pkgparm, output logic [7:0] o_sysbits, output logic [7:0] o_syshigh, output logic [7:0] o_fcall2, output logic [7:0] o_fcallv, output logic [7:0] o_negl1, output logic [7:0] o_shl2, output logic [7:0] o_shlu, output logic [7:0] o_sgnhex, output logic [7:0] o_sgnbin, output logic [7:0] o_sgndec, output logic [7:0] o_strl9, output logic [7:0] o_unkz, output logic [7:0] o_unkhx, output logic [7:0] o_unkhx2, output logic [7:0] o_unkox, output logic [7:0] o_wide70, output logic [7:0] o_wide96, output logic [7:0] o_wide65d, output logic [7:0] o_bigdec, output logic [7:0] o_xorn, output logic [7:0] o_negk, output logic [7:0] o_tcast, output logic [7:0] o_eqq, output logic [7:0] o_nested, output logic [7:0] o_uplus);
  assign o_plain = C_plain.c1;
  assign o_pkgref = C_pkgref.c1;
  assign o_pkgparm = C_pkgparm.c1;
  assign o_sysbits = C_sysbits.c1;
  assign o_syshigh = C_syshigh.c1;
  assign o_fcall2 = C_fcall2.c1;
  assign o_fcallv = C_fcallv.c1;
  assign o_negl1 = C_negl1.c1;
  assign o_shl2 = C_shl2.c1;
  assign o_shlu = C_shlu.c1;
  assign o_sgnhex = C_sgnhex.c1;
  assign o_sgnbin = C_sgnbin.c1;
  assign o_sgndec = C_sgndec.c1;
  assign o_strl9 = C_strl9.c1;
  assign o_unkz = C_unkz.c1;
  assign o_unkhx = C_unkhx.c1;
  assign o_unkhx2 = C_unkhx2.c1;
  assign o_unkox = C_unkox.c1;
  assign o_wide70 = C_wide70.c1;
  assign o_wide96 = C_wide96.c1;
  assign o_wide65d = C_wide65d.c1;
  assign o_bigdec = C_bigdec.c1;
  assign o_xorn = C_xorn.c1;
  assign o_negk = C_negk.c1;
  assign o_tcast = C_tcast.c1;
  assign o_eqq = C_eqq.c1;
  assign o_nested = C_nested.c1;
  assign o_uplus = C_uplus.c1;
endmodule

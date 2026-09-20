// r11u68 arm b1 — THE BAIL DETECTOR (LAW A's refusal set, measured).
// Each row is ONE packed struct: operand 0 is the CANDIDATE, operands 1 and 2
// are the SAME control `K + 1`, whose own reduce size is 64 while the member
// is 8 bits wide.  `expandPatternAssignment` re-sizes every operand it reaches
// to the member width and RETURNS at the first operand whose reduce or
// `get_uvalue` fails, so golden's control sizes read the refusal directly:
//   ctl = 8   -> the walk COMPLETED (the candidate did not refuse)
//   ctl = 64  -> the walk BAILED at the candidate
// `plain` is the NO-BAIL POSITIVE CONTROL: a scorer that reads every row as a
// bail is caught by it.
package qb;
  localparam int K = 6;
  localparam int unsigned KU = 6;
  typedef enum logic [7:0] { E_A = 8'd9, E_B = 8'd10 } e_t;
  function automatic int f_id(int x); return x; endfunction
  function automatic int f_neg(int x); return -x; endfunction
  typedef struct packed {
    logic [7:0] p;    // the candidate
    logic [7:0] c1;   // K + 1   -- control
    logic [7:0] c2;   // K + 1   -- control
  } bt_t;
  localparam bt_t L_plain = '{p: 3, c1: K + 1, c2: K + 1};  // a plain unsized decimal -- NO-BAIL POSITIVE CONTROL
  localparam bt_t L_mul = '{p: K * 2, c1: K + 1, c2: K + 1};  // an INT-arm product, positive
  localparam bt_t L_zsub = '{p: K - K, c1: K + 1, c2: K + 1};  // INT:0 out of a subtract (parses as uint)
  localparam bt_t L_xor = '{p: KU ^ 3, c1: K + 1, c2: K + 1};  // the XOR the reduce table refuses
  localparam bt_t L_cmpg = '{p: K > 2, c1: K + 1, c2: K + 1};  // a comparison
  localparam bt_t L_tern = '{p: K ? 3 : 4, c1: K + 1, c2: K + 1};  // a ternary
  localparam bt_t L_cstint = '{p: int'(K), c1: K + 1, c2: K + 1};  // an int'() cast
  localparam bt_t L_cstbyt = '{p: byte'(7), c1: K + 1, c2: K + 1};  // a named-type cast
  localparam bt_t L_cstsz = '{p: 8'(7), c1: K + 1, c2: K + 1};  // a size cast
  localparam bt_t L_concat = '{p: {4'd1, 4'd2}, c1: K + 1, c2: K + 1};  // a concatenation
  localparam bt_t L_repl = '{p: {2{4'd3}}, c1: K + 1, c2: K + 1};  // a replication
  localparam bt_t L_sysc = '{p: $clog2(40), c1: K + 1, c2: K + 1};  // a system call
  localparam bt_t L_fcall = '{p: f_id(6), c1: K + 1, c2: K + 1};  // a constant function call
  localparam bt_t L_fneg = '{p: f_neg(6), c1: K + 1, c2: K + 1};  // a function call returning NEGATIVE
  localparam bt_t L_negk = '{p: -K, c1: K + 1, c2: K + 1};  // a unary minus over a name
  localparam bt_t L_negl = '{p: 2 - 5, c1: K + 1, c2: K + 1};  // a negative out of a subtract
  localparam bt_t L_negm = '{p: -0, c1: K + 1, c2: K + 1};  // unary minus over zero
  localparam bt_t L_uwrap = '{p: KU - 5, c1: K + 1, c2: K + 1};  // an UNSIGNED wrap (golden INT:-2, slang positive)
  localparam bt_t L_unkx = '{p: 1'bx, c1: K + 1, c2: K + 1};  // an unknown bit, no valid leading digit
  localparam bt_t L_unk1 = '{p: 4'b1x01, c1: K + 1, c2: K + 1};  // an unknown bit BEHIND a valid leading 1
  localparam bt_t L_notu = '{p: ~KU, c1: K + 1, c2: K + 1};  // a bitwise NOT
  localparam bt_t L_shbig = '{p: KU << 40, c1: K + 1, c2: K + 1};  // a big shift
  localparam bt_t L_enumm = '{p: E_A, c1: K + 1, c2: K + 1};  // an enum member
  localparam bt_t L_unsz = '{p: '1, c1: K + 1, c2: K + 1};  // an unbased-unsized literal
  localparam bt_t L_hexl = '{p: 8'hA5, c1: K + 1, c2: K + 1};  // a based HEX literal
  localparam bt_t L_binl = '{p: 8'b1010_0101, c1: K + 1, c2: K + 1};  // a based BIN literal
  localparam bt_t L_decl = '{p: 8'd42, c1: K + 1, c2: K + 1};  // a based DEC literal
  localparam bt_t L_strl = '{p: "ab", c1: K + 1, c2: K + 1};  // a string literal
endpackage
module b1_refuse68 #(parameter qb::bt_t C_plain = qb::L_plain,
                parameter qb::bt_t C_mul = qb::L_mul,
                parameter qb::bt_t C_zsub = qb::L_zsub,
                parameter qb::bt_t C_xor = qb::L_xor,
                parameter qb::bt_t C_cmpg = qb::L_cmpg,
                parameter qb::bt_t C_tern = qb::L_tern,
                parameter qb::bt_t C_cstint = qb::L_cstint,
                parameter qb::bt_t C_cstbyt = qb::L_cstbyt,
                parameter qb::bt_t C_cstsz = qb::L_cstsz,
                parameter qb::bt_t C_concat = qb::L_concat,
                parameter qb::bt_t C_repl = qb::L_repl,
                parameter qb::bt_t C_sysc = qb::L_sysc,
                parameter qb::bt_t C_fcall = qb::L_fcall,
                parameter qb::bt_t C_fneg = qb::L_fneg,
                parameter qb::bt_t C_negk = qb::L_negk,
                parameter qb::bt_t C_negl = qb::L_negl,
                parameter qb::bt_t C_negm = qb::L_negm,
                parameter qb::bt_t C_uwrap = qb::L_uwrap,
                parameter qb::bt_t C_unkx = qb::L_unkx,
                parameter qb::bt_t C_unk1 = qb::L_unk1,
                parameter qb::bt_t C_notu = qb::L_notu,
                parameter qb::bt_t C_shbig = qb::L_shbig,
                parameter qb::bt_t C_enumm = qb::L_enumm,
                parameter qb::bt_t C_unsz = qb::L_unsz,
                parameter qb::bt_t C_hexl = qb::L_hexl,
                parameter qb::bt_t C_binl = qb::L_binl,
                parameter qb::bt_t C_decl = qb::L_decl,
                parameter qb::bt_t C_strl = qb::L_strl)
                (output logic [31:0] y_plain,
                 output logic [31:0] y_mul,
                 output logic [31:0] y_zsub,
                 output logic [31:0] y_xor,
                 output logic [31:0] y_cmpg,
                 output logic [31:0] y_tern,
                 output logic [31:0] y_cstint,
                 output logic [31:0] y_cstbyt,
                 output logic [31:0] y_cstsz,
                 output logic [31:0] y_concat,
                 output logic [31:0] y_repl,
                 output logic [31:0] y_sysc,
                 output logic [31:0] y_fcall,
                 output logic [31:0] y_fneg,
                 output logic [31:0] y_negk,
                 output logic [31:0] y_negl,
                 output logic [31:0] y_negm,
                 output logic [31:0] y_uwrap,
                 output logic [31:0] y_unkx,
                 output logic [31:0] y_unk1,
                 output logic [31:0] y_notu,
                 output logic [31:0] y_shbig,
                 output logic [31:0] y_enumm,
                 output logic [31:0] y_unsz,
                 output logic [31:0] y_hexl,
                 output logic [31:0] y_binl,
                 output logic [31:0] y_decl,
                 output logic [31:0] y_strl);
  assign y_plain = {C_plain.p, C_plain.c1, C_plain.c2};
  assign y_mul = {C_mul.p, C_mul.c1, C_mul.c2};
  assign y_zsub = {C_zsub.p, C_zsub.c1, C_zsub.c2};
  assign y_xor = {C_xor.p, C_xor.c1, C_xor.c2};
  assign y_cmpg = {C_cmpg.p, C_cmpg.c1, C_cmpg.c2};
  assign y_tern = {C_tern.p, C_tern.c1, C_tern.c2};
  assign y_cstint = {C_cstint.p, C_cstint.c1, C_cstint.c2};
  assign y_cstbyt = {C_cstbyt.p, C_cstbyt.c1, C_cstbyt.c2};
  assign y_cstsz = {C_cstsz.p, C_cstsz.c1, C_cstsz.c2};
  assign y_concat = {C_concat.p, C_concat.c1, C_concat.c2};
  assign y_repl = {C_repl.p, C_repl.c1, C_repl.c2};
  assign y_sysc = {C_sysc.p, C_sysc.c1, C_sysc.c2};
  assign y_fcall = {C_fcall.p, C_fcall.c1, C_fcall.c2};
  assign y_fneg = {C_fneg.p, C_fneg.c1, C_fneg.c2};
  assign y_negk = {C_negk.p, C_negk.c1, C_negk.c2};
  assign y_negl = {C_negl.p, C_negl.c1, C_negl.c2};
  assign y_negm = {C_negm.p, C_negm.c1, C_negm.c2};
  assign y_uwrap = {C_uwrap.p, C_uwrap.c1, C_uwrap.c2};
  assign y_unkx = {C_unkx.p, C_unkx.c1, C_unkx.c2};
  assign y_unk1 = {C_unk1.p, C_unk1.c1, C_unk1.c2};
  assign y_notu = {C_notu.p, C_notu.c1, C_notu.c2};
  assign y_shbig = {C_shbig.p, C_shbig.c1, C_shbig.c2};
  assign y_enumm = {C_enumm.p, C_enumm.c1, C_enumm.c2};
  assign y_unsz = {C_unsz.p, C_unsz.c1, C_unsz.c2};
  assign y_hexl = {C_hexl.p, C_hexl.c1, C_hexl.c2};
  assign y_binl = {C_binl.p, C_binl.c1, C_binl.c2};
  assign y_decl = {C_decl.p, C_decl.c1, C_decl.c2};
  assign y_strl = {C_strl.p, C_strl.c1, C_strl.c2};
endmodule

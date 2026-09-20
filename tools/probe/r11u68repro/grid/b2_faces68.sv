// r11u68 arm b2 — THE REFUSAL SET RESOLVED: the CAST face, the SIGNEDNESS
// face (where slang's own evaluation and Surelog's reduce can disagree) and
// the UNKNOWN-DIGIT face (leading vs interior).  Same detector as b1: golden
// sizes the two controls 8 when the walk completed and 64 when it bailed.
package qc;
  localparam int K = 6;
  localparam int KS = 0;
  localparam int unsigned KU = 6;
  localparam int NEGP = -5;
  localparam logic signed [7:0] SHF = 8'shFF;
  typedef logic [7:0] m8_t;
  typedef enum logic [7:0] { E_A = 8'd9, E_B = 8'd10 } e_t;
  typedef struct packed {
    logic [7:0] p;    // the candidate
    logic [7:0] c1;   // K + 1   -- control
    logic [7:0] c2;   // K + 1   -- control
  } ct_t;
  localparam ct_t M_plain = '{p: 3, c1: K + 1, c2: K + 1};  // NO-BAIL POSITIVE CONTROL
  localparam ct_t M_cbyte = '{p: byte'(7), c1: K + 1, c2: K + 1};  // byte'()
  localparam ct_t M_cshort = '{p: shortint'(7), c1: K + 1, c2: K + 1};  // shortint'()
  localparam ct_t M_cint = '{p: int'(7), c1: K + 1, c2: K + 1};  // int'()
  localparam ct_t M_cinteg = '{p: integer'(7), c1: K + 1, c2: K + 1};  // integer'()
  localparam ct_t M_clong = '{p: longint'(7), c1: K + 1, c2: K + 1};  // longint'()
  localparam ct_t M_cbit = '{p: bit'(1), c1: K + 1, c2: K + 1};  // bit'()
  localparam ct_t M_clogic = '{p: logic'(1), c1: K + 1, c2: K + 1};  // logic'()
  localparam ct_t M_cenum = '{p: e_t'(9), c1: K + 1, c2: K + 1};  // an enum-type cast
  localparam ct_t M_ctdef = '{p: m8_t'(7), c1: K + 1, c2: K + 1};  // a typedef'd vector cast
  localparam ct_t M_csz8 = '{p: 8'(7), c1: K + 1, c2: K + 1};  // a size cast
  localparam ct_t M_csz32 = '{p: 32'(7), c1: K + 1, c2: K + 1};  // a wider size cast
  localparam ct_t M_cuns = '{p: unsigned'(K), c1: K + 1, c2: K + 1};  // unsigned'()
  localparam ct_t M_csgn = '{p: signed'(K), c1: K + 1, c2: K + 1};  // signed'()
  localparam ct_t M_dsuns = '{p: $unsigned(K), c1: K + 1, c2: K + 1};  // $unsigned()
  localparam ct_t M_dssgn = '{p: $signed(K), c1: K + 1, c2: K + 1};  // $signed()
  localparam ct_t M_nparm = '{p: NEGP, c1: K + 1, c2: K + 1};  // a NAME whose init is -5
  localparam ct_t M_nshf = '{p: SHF, c1: K + 1, c2: K + 1};  // a NAME whose init is 8'shFF (slang -1)
  localparam ct_t M_nlit = '{p: 8'shFF, c1: K + 1, c2: K + 1};  // a signed HEX literal passed through (slang -1)
  localparam ct_t M_nsb = '{p: 8'sb11111111, c1: K + 1, c2: K + 1};  // a signed BIN literal passed through
  localparam ct_t M_nsd = '{p: -8'sd1, c1: K + 1, c2: K + 1};  // unary minus over a signed decimal
  localparam ct_t M_ns1 = '{p: 1'sb1, c1: K + 1, c2: K + 1};  // a 1-bit signed literal (slang -1)
  localparam ct_t M_nsub = '{p: KS - 1, c1: K + 1, c2: K + 1};  // KS(int)=0 minus 1
  localparam ct_t M_nmulp = '{p: K * KS, c1: K + 1, c2: K + 1};  // a product that is ZERO
  localparam ct_t M_xlead = '{p: 8'bx0000001, c1: K + 1, c2: K + 1};  // an unknown LEADING bit
  localparam ct_t M_xtail = '{p: 8'b1000000x, c1: K + 1, c2: K + 1};  // an unknown TRAILING bit
  localparam ct_t M_xz = '{p: 8'bz0000001, c1: K + 1, c2: K + 1};  // a leading Z
  localparam ct_t M_xq = '{p: 8'b?0000001, c1: K + 1, c2: K + 1};  // a leading ?
  localparam ct_t M_w96 = '{p: 96'h123456789ABCDEF012345678, c1: K + 1, c2: K + 1};  // a >64-bit hex literal
  localparam ct_t M_w65 = '{p: 65'd1, c1: K + 1, c2: K + 1};  // a 65-bit decimal literal
  localparam ct_t M_wb96 = '{p: 96'b1, c1: K + 1, c2: K + 1};  // a >64-bit binary literal
endpackage
module b2_faces68 #(parameter qc::ct_t C_plain = qc::M_plain,
                parameter qc::ct_t C_cbyte = qc::M_cbyte,
                parameter qc::ct_t C_cshort = qc::M_cshort,
                parameter qc::ct_t C_cint = qc::M_cint,
                parameter qc::ct_t C_cinteg = qc::M_cinteg,
                parameter qc::ct_t C_clong = qc::M_clong,
                parameter qc::ct_t C_cbit = qc::M_cbit,
                parameter qc::ct_t C_clogic = qc::M_clogic,
                parameter qc::ct_t C_cenum = qc::M_cenum,
                parameter qc::ct_t C_ctdef = qc::M_ctdef,
                parameter qc::ct_t C_csz8 = qc::M_csz8,
                parameter qc::ct_t C_csz32 = qc::M_csz32,
                parameter qc::ct_t C_cuns = qc::M_cuns,
                parameter qc::ct_t C_csgn = qc::M_csgn,
                parameter qc::ct_t C_dsuns = qc::M_dsuns,
                parameter qc::ct_t C_dssgn = qc::M_dssgn,
                parameter qc::ct_t C_nparm = qc::M_nparm,
                parameter qc::ct_t C_nshf = qc::M_nshf,
                parameter qc::ct_t C_nlit = qc::M_nlit,
                parameter qc::ct_t C_nsb = qc::M_nsb,
                parameter qc::ct_t C_nsd = qc::M_nsd,
                parameter qc::ct_t C_ns1 = qc::M_ns1,
                parameter qc::ct_t C_nsub = qc::M_nsub,
                parameter qc::ct_t C_nmulp = qc::M_nmulp,
                parameter qc::ct_t C_xlead = qc::M_xlead,
                parameter qc::ct_t C_xtail = qc::M_xtail,
                parameter qc::ct_t C_xz = qc::M_xz,
                parameter qc::ct_t C_xq = qc::M_xq,
                parameter qc::ct_t C_w96 = qc::M_w96,
                parameter qc::ct_t C_w65 = qc::M_w65,
                parameter qc::ct_t C_wb96 = qc::M_wb96)
                (output logic [31:0] y_plain,
                 output logic [31:0] y_cbyte,
                 output logic [31:0] y_cshort,
                 output logic [31:0] y_cint,
                 output logic [31:0] y_cinteg,
                 output logic [31:0] y_clong,
                 output logic [31:0] y_cbit,
                 output logic [31:0] y_clogic,
                 output logic [31:0] y_cenum,
                 output logic [31:0] y_ctdef,
                 output logic [31:0] y_csz8,
                 output logic [31:0] y_csz32,
                 output logic [31:0] y_cuns,
                 output logic [31:0] y_csgn,
                 output logic [31:0] y_dsuns,
                 output logic [31:0] y_dssgn,
                 output logic [31:0] y_nparm,
                 output logic [31:0] y_nshf,
                 output logic [31:0] y_nlit,
                 output logic [31:0] y_nsb,
                 output logic [31:0] y_nsd,
                 output logic [31:0] y_ns1,
                 output logic [31:0] y_nsub,
                 output logic [31:0] y_nmulp,
                 output logic [31:0] y_xlead,
                 output logic [31:0] y_xtail,
                 output logic [31:0] y_xz,
                 output logic [31:0] y_xq,
                 output logic [31:0] y_w96,
                 output logic [31:0] y_w65,
                 output logic [31:0] y_wb96);
  assign y_plain = {C_plain.p, C_plain.c1, C_plain.c2};
  assign y_cbyte = {C_cbyte.p, C_cbyte.c1, C_cbyte.c2};
  assign y_cshort = {C_cshort.p, C_cshort.c1, C_cshort.c2};
  assign y_cint = {C_cint.p, C_cint.c1, C_cint.c2};
  assign y_cinteg = {C_cinteg.p, C_cinteg.c1, C_cinteg.c2};
  assign y_clong = {C_clong.p, C_clong.c1, C_clong.c2};
  assign y_cbit = {C_cbit.p, C_cbit.c1, C_cbit.c2};
  assign y_clogic = {C_clogic.p, C_clogic.c1, C_clogic.c2};
  assign y_cenum = {C_cenum.p, C_cenum.c1, C_cenum.c2};
  assign y_ctdef = {C_ctdef.p, C_ctdef.c1, C_ctdef.c2};
  assign y_csz8 = {C_csz8.p, C_csz8.c1, C_csz8.c2};
  assign y_csz32 = {C_csz32.p, C_csz32.c1, C_csz32.c2};
  assign y_cuns = {C_cuns.p, C_cuns.c1, C_cuns.c2};
  assign y_csgn = {C_csgn.p, C_csgn.c1, C_csgn.c2};
  assign y_dsuns = {C_dsuns.p, C_dsuns.c1, C_dsuns.c2};
  assign y_dssgn = {C_dssgn.p, C_dssgn.c1, C_dssgn.c2};
  assign y_nparm = {C_nparm.p, C_nparm.c1, C_nparm.c2};
  assign y_nshf = {C_nshf.p, C_nshf.c1, C_nshf.c2};
  assign y_nlit = {C_nlit.p, C_nlit.c1, C_nlit.c2};
  assign y_nsb = {C_nsb.p, C_nsb.c1, C_nsb.c2};
  assign y_nsd = {C_nsd.p, C_nsd.c1, C_nsd.c2};
  assign y_ns1 = {C_ns1.p, C_ns1.c1, C_ns1.c2};
  assign y_nsub = {C_nsub.p, C_nsub.c1, C_nsub.c2};
  assign y_nmulp = {C_nmulp.p, C_nmulp.c1, C_nmulp.c2};
  assign y_xlead = {C_xlead.p, C_xlead.c1, C_xlead.c2};
  assign y_xtail = {C_xtail.p, C_xtail.c1, C_xtail.c2};
  assign y_xz = {C_xz.p, C_xz.c1, C_xz.c2};
  assign y_xq = {C_xq.p, C_xq.c1, C_xq.c2};
  assign y_w96 = {C_w96.p, C_w96.c1, C_w96.c2};
  assign y_w65 = {C_w65.p, C_w65.c1, C_w65.c2};
  assign y_wb96 = {C_wb96.p, C_wb96.c1, C_wb96.c2};
endmodule

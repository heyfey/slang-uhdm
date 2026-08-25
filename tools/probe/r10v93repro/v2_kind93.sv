// v93 adversarial arm V2 — cast-target kinds and operand classes.
package v2pkg;
  typedef logic [63:0]        v64_t;
  typedef logic [95:0]        v96_t;
  typedef bit   [63:0]        b64_t;
  typedef logic signed [63:0] s64_t;
  typedef enum logic [63:0] { E_A = 64'd1, E_B = 64'd2 } e64_t;
  typedef struct packed { logic [31:0] a; logic [31:0] b; } st64_t;
  parameter int WP = 64;
endpackage

module v2_top (input logic clk, output logic [63:0] o);
  import v2pkg::*;
  localparam logic [63:0] OP    = 64'hFFFF_FFFF_FFFF_FFFF;
  localparam logic [63:0] k_int    = int'(OP);
  localparam logic [63:0] k_lint   = longint'(OP);
  localparam logic [63:0] k_sint   = shortint'(OP);
  localparam logic [63:0] k_byte   = byte'(OP);
  localparam logic [63:0] k_bit    = bit'(OP);
  localparam logic [63:0] k_logic  = logic'(OP);
  localparam logic [63:0] k_time   = time'(OP);
  localparam logic [63:0] k_integ  = integer'(OP);
  localparam logic [63:0] k_v64    = v64_t'(OP);
  localparam logic [95:0] k_v96    = v96_t'(OP);
  localparam logic [63:0] k_b64    = b64_t'(OP);
  localparam logic signed [63:0] k_s64 = s64_t'(OP);
  localparam logic [63:0] k_e64    = e64_t'(64'd1);
  localparam logic [63:0] k_st64   = st64_t'(OP);
  localparam logic [63:0] k_sz64   = 64'(OP);
  localparam logic [95:0] k_sz96   = 96'(OP);
  localparam logic [63:0] k_szp    = WP'(OP);
  localparam logic [63:0] k_e64w   = E_B'(OP);
  // operand classes
  localparam logic [63:0] k_o_0    = 64'(0);
  localparam logic [63:0] k_o_1    = 64'(1);
  localparam logic [63:0] k_o_m1   = 64'(-1);
  localparam logic [63:0] k_o_hi   = 64'(64'h8000_0000_0000_0000);
  localparam logic [95:0] k_o_w96  = 96'(96'd5);
  localparam logic [63:0] k_o_str  = 64'("abcd");
  localparam logic [63:0] k_o_uns  = 64'('1);
  localparam logic [63:0] k_o_par  = 64'(OP);
  localparam logic [63:0] k_o_exp  = 64'(OP + 64'd1);
  localparam logic [63:0] k_o_nest = 96'(65'(OP));
  localparam logic [63:0] k_o_bits = 64'($bits(OP));
  localparam logic [63:0] k_o_xz   = 64'(64'hFFFF_FFFF_FFFF_FFFX);
  localparam logic signed [63:0] k_o_sg = 64'(signed'(OP));
  localparam logic [63:0] k_ctl32  = 32'(OP);
  localparam logic [63:0] k_ctl63  = 63'(OP);
  assign o = k_int^k_lint^k_sint^k_byte^k_bit^k_logic^k_time^k_integ^k_v64^k_v96[63:0]
           ^ k_b64^k_s64^k_e64^k_st64^k_sz64^k_sz96[63:0]^k_szp^k_e64w
           ^ k_o_0^k_o_1^k_o_m1^k_o_hi^k_o_w96[63:0]^k_o_str^k_o_uns^k_o_par^k_o_exp
           ^ k_o_nest^k_o_bits^k_o_xz^k_o_sg^k_ctl32^k_ctl63^{64{clk}};
endmodule

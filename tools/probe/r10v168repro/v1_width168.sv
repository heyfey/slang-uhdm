// r10v168repro/v1_width168.sv — MEASUREMENT ONLY (adversarial verifier of
// r10uvm168 § enumOriginConstTypeIsTheMemberValue168).
//
// FACE: the enum BASE (width 1..64+, signed vs unsigned vs a TYPEDEF'd base)
// crossed with values AT THE WIDTH BOUNDARY, read at a package parameter whose
// Rhs is a bare reference to the member.  Cell = the folded constant's
// vpiConstType.  Names carry no ordering hint and no shared prefix pattern
// with the implementer's arms.
package brail_pkg;

  // ---- width 1 -------------------------------------------------------
  typedef enum bit [0:0] { FEN_LOW, FEN_TOP } fen_e;
  parameter fen_e w_bit1_lo  = FEN_LOW;      // v101
  parameter fen_e w_bit1_hi  = FEN_TOP;      // v102

  typedef enum logic [0:0] { OAST_OFF = 1'b1 } oast_e;
  parameter oast_e w_l1_bin  = OAST_OFF;     // v103 (BIN, pre-existing arm)

  typedef enum bit [0:0] { LAVE_D = 1'd1 } lave_e;
  parameter lave_e w_l1_dec  = LAVE_D;       // v104 BASED-DEC at width 1

  // ---- width 2, all four codepoints, auto ----------------------------
  typedef enum logic [1:0] { NUB_A, NUB_B, NUB_C, NUB_D } nub_e;
  parameter nub_e w_w2_zero  = NUB_A;        // v105 zero-mapped
  parameter nub_e w_w2_three = NUB_D;        // v106 top codepoint

  // ---- width 7 / 8 / 9, boundary values ------------------------------
  typedef enum bit [7:0] { GRIST_MAX = 8'hFF, GRIST_WRAP = 8'd0 } grist_e;
  parameter grist_e w_hexmax = GRIST_MAX;    // v107 HEX at max
  parameter grist_e w_decnil = GRIST_WRAP;   // v108 BASED-DEC zero

  typedef enum logic [8:0] { SPELT_HI = 9'd256, SPELT_ROLL } spelt_e;
  parameter spelt_e w_w9_dec = SPELT_HI;     // v109 BASED-DEC crossing 8 bits
  parameter spelt_e w_w9_aut = SPELT_ROLL;   // v110 auto after it

  // ---- width 31/32/33 around the int boundary ------------------------
  typedef enum bit [30:0] { KERF_TOP = 31'd2147483647 } kerf_e;
  parameter kerf_e w_w31_max = KERF_TOP;     // v111

  typedef enum bit [31:0] { LOAM_SIGNBIT = 32'd2147483648, LOAM_NEXT } loam_e;
  parameter loam_e w_w32_sgn = LOAM_SIGNBIT; // v112 sign bit of 32
  parameter loam_e w_w32_aut = LOAM_NEXT;    // v113 auto past it

  typedef enum logic signed [31:0] { MARL_NEG = -2147483647, MARL_UP } marl_e;
  parameter marl_e w_s32_neg = MARL_NEG;     // v114 negative-mapped
  parameter marl_e w_s32_aut = MARL_UP;      // v115 auto after a negative

  typedef enum bit [32:0] { NOIL_BIG = 33'd4294967296 } noil_e;
  parameter noil_e w_w33_dec = NOIL_BIG;     // v116

  // ---- width 63/64 ----------------------------------------------------
  typedef enum bit [62:0] { PLASH_ONE, PLASH_TWO } plash_e;
  parameter plash_e w_w63_aut = PLASH_TWO;   // v117 auto at width 63

  typedef enum bit [63:0] { QUERN_HI = 64'd9223372036854775808, QUERN_NX } quern_e;
  parameter quern_e w_w64_dec = QUERN_HI;    // v118 BASED-DEC at 2**63
  parameter quern_e w_w64_aut = QUERN_NX;    // v119 auto past 2**63

  typedef enum logic [63:0] { RAMSON_FF = 64'hFFFF_FFFF_FFFF_FFFF } ramson_e;
  parameter ramson_e w_w64_hex = RAMSON_FF;  // v120 HEX at 64-bit max

  typedef enum bit [63:0] { SEDGE_OCT = 64'o1777777777777777777777 } sedge_e;
  parameter sedge_e w_w64_oct = SEDGE_OCT;   // v121 OCTAL that overflows the
                                             //      implementer's ov guard

  typedef enum logic [63:0] { TILTH_OCT = 64'o7654321 } tilth_e;
  parameter tilth_e w_w64_oc2 = TILTH_OCT;   // v122 small octal in a wide enum

  // ---- wider than 64 (the INT:-re-prefix must DECLINE) ----------------
  typedef enum bit [95:0] { UMBER_NIL, UMBER_ONE } umber_e;
  parameter umber_e w_w96_aut = UMBER_ONE;   // v123

  typedef enum logic [127:0] { VERGE_HX = 128'h1234_5678_9abc_def0_1234_5678_9abc_def0 } verge_e;
  parameter verge_e w_w128_hx = VERGE_HX;    // v124

  // ---- TYPEDEF'd base, unsigned / signed ------------------------------
  typedef bit [7:0]          octet_t;
  typedef logic signed [7:0] soctet_t;
  typedef enum octet_t  { WHIN_NIL, WHIN_ONE } whin_e;
  typedef enum soctet_t { YARROW_LOW = -5, YARROW_UP } yarrow_e;
  parameter whin_e   w_tdb_aut  = WHIN_ONE;    // v125 typedef'd unsigned base
  parameter yarrow_e w_tdb_neg  = YARROW_LOW;  // v126 typedef'd signed base
  parameter yarrow_e w_tdb_naut = YARROW_UP;   // v127 auto after negative

  // ---- an enum whose base is a typedef of a PREDEFINED signed type -----
  typedef int  intish_t;
  typedef enum intish_t { ZEBEC_NIL, ZEBEC_TWO = 2, ZEBEC_THREE } zebec_e;
  parameter zebec_e w_tdi_aut = ZEBEC_NIL;   // v128
  parameter zebec_e w_tdi_udc = ZEBEC_TWO;   // v129 unsized decimal member
  parameter zebec_e w_tdi_nxt = ZEBEC_THREE; // v130 auto after unsized decimal

  // ---- auto member DIRECTLY AFTER a hex / binary / octal member --------
  typedef enum logic [7:0] { ANLACE_H = 8'hA5, ANLACE_HN } anlace_e;
  typedef enum logic [7:0] { BODLE_B  = 8'b1010_0101, BODLE_BN } bodle_e;
  typedef enum logic [7:0] { CRWTH_O  = 8'o245, CRWTH_ON } crwth_e;
  parameter anlace_e w_afterhex = ANLACE_HN; // v131
  parameter bodle_e  w_afterbin = BODLE_BN;  // v132
  parameter crwth_e  w_afteroct = CRWTH_ON;  // v133

endpackage

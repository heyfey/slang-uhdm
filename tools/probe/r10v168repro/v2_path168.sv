// r10v168repro/v2_path168.sv — MEASUREMENT ONLY.
// FACE: HOW the parameter reaches the enum constant — a direct reference, one
// or two parameter hops, an arithmetic fold, a cast, a concatenation, a
// ternary, a parenthesised reference, a scoped (pkg::) name — crossed with the
// parameter's OWN declared type (enum typedef / int / integer / signed and
// unsigned vectors of several widths / untyped) and with parameter vs
// localparam.  Also carries the STRING and REAL negative controls.
package ferrule_pkg;
  typedef enum { NOG_NIL, NOG_ONE, NOG_TWO, NOG_TRI } nog_e;
  parameter nog_e SEED_TRI = NOG_TRI;
endpackage

package hansa_pkg;
  import ferrule_pkg::*;

  typedef enum { BOSK_NIL, BOSK_ONE, BOSK_TWO, BOSK_TRI } bosk_e;
  typedef logic [11:0] dozen_v_t;
  typedef enum bit [7:0] { CRAG_D = 8'd12, CRAG_NEXT } crag_e;

  // ---- direct reference, parameter's own declared type varies ---------
  parameter bosk_e     p_as_enum = BOSK_TWO;          // v201
  parameter int        p_as_int  = BOSK_TWO;          // v202
  parameter integer    p_as_intg = BOSK_TWO;          // v203
  parameter byte       p_as_byte = BOSK_TWO;          // v204
  parameter shortint   p_as_shrt = BOSK_TWO;          // v205
  parameter longint    p_as_long = BOSK_TWO;          // v206
  parameter bit        p_as_b1   = BOSK_ONE;          // v207 width 1
  parameter bit [3:0]  p_as_b4   = BOSK_TWO;          // v208
  parameter logic [7:0] p_as_l8  = BOSK_TWO;          // v209
  parameter bit signed [15:0]  p_as_s16 = BOSK_TWO;   // v210
  parameter bit [63:0] p_as_b64  = BOSK_TWO;          // v211 width 64
  parameter logic signed [63:0] p_as_s64 = BOSK_TWO;  // v212
  parameter            p_untyped = BOSK_TWO;          // v213 UNTYPED control

  // ---- localparam vs parameter ---------------------------------------
  localparam bosk_e    lp_enum   = BOSK_TRI;          // v214
  localparam int       lp_int    = BOSK_TRI;          // v215

  // ---- one and two parameter HOPS ------------------------------------
  parameter bosk_e     hop_a     = BOSK_ONE;
  parameter bosk_e     hop_b     = hop_a;             // v216 one hop
  parameter int        hop_c     = hop_b;             // v217 two hops
  parameter int        hop_d     = hop_c;             // v218 three hops

  // ---- parenthesised / redundant parens -------------------------------
  parameter bosk_e     par_one   = (BOSK_TWO);        // v219
  parameter int        par_two   = ((BOSK_TWO));      // v220

  // ---- CASTS (must NOT take the member encoding) ----------------------
  parameter int        cst_int   = int'(BOSK_TWO);    // v221
  parameter bit [7:0]  cst_wid   = 8'(BOSK_TWO);      // v222
  // NOTE: `bosk_e'(BOSK_TWO)` — a NAMED-ENUM-TYPE cast of an enum member — is
  // rejected by slang-uhdm itself ("expression kind: Invalid") on BOTH
  // binaries at BASE 39f286ef.  Pre-existing, unrelated to this law, recorded
  // here so the arm stays compilable; the cast face is covered by v221/v222/
  // v224/v225 and by a typedef'd-vector cast below.
  parameter int        cst_dbl   = int'(int'(BOSK_TWO)); // v223 nested cast
  parameter int        cst_sgn   = signed'(BOSK_TWO); // v224
  parameter int        cst_uns   = unsigned'(BOSK_TWO); // v225

  // ---- ARITHMETIC and other folds ------------------------------------
  parameter int        ar_add    = BOSK_TWO + 1;      // v226
  parameter int        ar_sub    = BOSK_TRI - 1;      // v227
  parameter int        ar_mul    = BOSK_TWO * 2;      // v228
  parameter int        ar_neg    = -BOSK_TWO;         // v229
  parameter bit [7:0]  ar_cat    = {4'd0, 4'(BOSK_TWO)}; // v230
  parameter int        ar_tern   = (1) ? BOSK_TWO : BOSK_ONE; // v231
  parameter int        ar_ors    = BOSK_TWO | 0;      // v232

  // ---- SCOPED (pkg::) reference and a hop through an IMPORTED param ---
  parameter nog_e      sc_direct = ferrule_pkg::NOG_TWO;   // v233
  parameter int        sc_hop    = ferrule_pkg::SEED_TRI;  // v234
  parameter nog_e      sc_wild   = NOG_ONE;                // v235 wildcard-imported

  // ---- BASED-DECIMAL member reached each way --------------------------
  parameter crag_e     bd_direct = CRAG_D;            // v236
  parameter crag_e     bd_hopsrc = CRAG_D;
  parameter int        bd_hop    = bd_hopsrc;         // v237
  parameter int        bd_cast   = int'(CRAG_D);      // v238
  parameter crag_e     bd_auto   = CRAG_NEXT;         // v239

  // ---- STRING and REAL controls (no enum in the chain at all) ---------
  parameter string     ct_str    = "quoin";           // v240
  parameter real       ct_real   = 3.25;              // v241
  parameter shortreal  ct_sreal  = 1.5;               // v242
  parameter realtime   ct_rtime  = 2.0;               // v243
  parameter int        ct_plain  = 7;                 // v244
  parameter bit [7:0]  ct_hexlit = 8'hB4;             // v245
  parameter bit [7:0]  ct_declit = 8'd180;            // v246
  parameter bit [7:0]  ct_octlit = 8'o264;            // v247

endpackage

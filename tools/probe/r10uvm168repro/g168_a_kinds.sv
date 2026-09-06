// r10uvm168repro/g168_a_kinds.sv — MEASUREMENT ONLY.
// ARM A: the ENUM-MEMBER DECLARATION FORM × the enum's BASE TYPE, read at a
// PACKAGE parameter whose Rhs is a BARE reference to the member.  The cell is
// the folded constant's vpiConstType (7 = vpiIntConst, 9 = vpiUIntConst,
// 1 = vpiBinaryConst, 3 = vpiHexConst, 2 = vpiOctConst).
//
// Names deliberately carry NO ordering hint (no a_t/b_t/c_t, no 1/2/3 suffix
// pattern that mirrors the row order) — RESUME §9: a grid that names
// everything in its own order is self-confirming.
package tinct_pkg;

  // --- implicit base (no base type written): every member auto-numbered
  typedef enum { GLIM_ZERO, GLIM_ONE, GLIM_TWO, GLIM_THREE } glim_e;
  parameter glim_e ka_first  = GLIM_ZERO;    // a01 value 0
  parameter glim_e ka_mid    = GLIM_TWO;     // a02 value 2
  parameter glim_e ka_last   = GLIM_THREE;   // a03 value 3  (the corpus shape)

  // --- implicit base, member written as an UNSIZED DECIMAL
  typedef enum { RUST_SEED = 5, RUST_NEXT, RUST_JUMP = 9, RUST_TAIL } rust_e;
  parameter rust_e ka_udec   = RUST_SEED;    // a04 explicit 5
  parameter rust_e ka_udnext = RUST_NEXT;    // a05 auto AFTER an explicit
  parameter rust_e ka_udjump = RUST_JUMP;    // a06 explicit 9
  parameter rust_e ka_udtail = RUST_TAIL;    // a07 auto after 9

  // --- implicit base, member written NEGATIVE
  typedef enum { DRIFT_DOWN = -4, DRIFT_BACK } drift_e;
  parameter drift_e ka_neg   = DRIFT_DOWN;   // a08
  parameter drift_e ka_negup = DRIFT_BACK;   // a09

  // --- written base `int` (signed)
  typedef enum int { AXLE_ONE, AXLE_TWO, AXLE_SIX = 6 } axle_e;
  parameter axle_e ka_int0   = AXLE_ONE;     // a10
  parameter axle_e ka_int6   = AXLE_SIX;     // a11

  // --- written base `int unsigned`
  typedef enum int unsigned { NAVE_LOW, NAVE_HIGH } nave_e;
  parameter nave_e ka_uint   = NAVE_HIGH;    // a12

  // --- written base `byte` / `shortint` / `longint` / `integer`
  typedef enum byte      { QUAY_A, QUAY_B } quay_e;
  typedef enum shortint  { RILL_A, RILL_B } rill_e;
  typedef enum longint   { SPAR_A, SPAR_B } spar_e;
  typedef enum integer   { TARN_A, TARN_B } tarn_e;
  parameter quay_e ka_byte   = QUAY_B;       // a13
  parameter rill_e ka_short  = RILL_B;       // a14
  parameter spar_e ka_long   = SPAR_B;       // a15
  parameter tarn_e ka_integ  = TARN_B;       // a16

  // --- written base `logic [3:0]` (unsigned 4-bit), auto-numbered
  typedef enum logic [3:0] { SHIM_NIL, SHIM_ONE, SHIM_PAIR } shim_e;
  parameter shim_e ka_logic  = SHIM_PAIR;    // a17

  // --- written base `bit [3:0]`, auto-numbered
  typedef enum bit [3:0] { WELT_NIL, WELT_ONE } welt_e;
  parameter welt_e ka_bit    = WELT_ONE;     // a18

  // --- written base `logic signed [3:0]`
  typedef enum logic signed [3:0] { PIKE_NIL, PIKE_ONE } pike_e;
  parameter pike_e ka_slogic = PIKE_ONE;     // a19

  // --- member written as a BASED DECIMAL literal
  typedef enum bit [3:0] { COIL_TWO = 4'd2, COIL_NEXT } coil_e;
  parameter coil_e ka_bdec   = COIL_TWO;     // a20
  parameter coil_e ka_bdnext = COIL_NEXT;    // a21 auto after a based decimal

  // --- member written BINARY
  typedef enum logic [3:0] { VEIL_FIVE = 4'b0101, VEIL_NEXT } veil_e;
  parameter veil_e ka_bin    = VEIL_FIVE;    // a22
  parameter veil_e ka_bnext  = VEIL_NEXT;    // a23

  // --- member written HEX
  typedef enum logic [7:0] { MOSS_TAG = 8'h1f, MOSS_NEXT } moss_e;
  parameter moss_e ka_hex    = MOSS_TAG;     // a24
  parameter moss_e ka_hnext  = MOSS_NEXT;    // a25

  // --- member written OCTAL
  typedef enum logic [5:0] { PERN_ODD = 6'o17, PERN_NEXT } pern_e;
  parameter pern_e ka_oct    = PERN_ODD;     // a26
  parameter pern_e ka_onext  = PERN_NEXT;    // a27

  // --- member written as an UNSIZED BASED literal
  typedef enum logic [7:0] { HOLT_MARK = 'h20, HOLT_NEXT } holt_e;
  parameter holt_e ka_ubhex  = HOLT_MARK;    // a28
  parameter holt_e ka_ubnext = HOLT_NEXT;    // a29

  // --- member written as an EXPRESSION over an earlier member
  typedef enum { KELP_BASE = 3, KELP_STEP = KELP_BASE + 4 } kelp_e;
  parameter kelp_e ka_expr   = KELP_STEP;    // a30

  // --- ANONYMOUS enum (no typedef) declared straight on a variable's type
  //     is not referenceable as a parameter type; use a typedef'd twin whose
  //     members carry an X in the value (unknowns take a different Value arm).
  typedef enum logic [3:0] { GORSE_X = 4'bx1x0 } gorse_e;
  parameter gorse_e ka_xz    = GORSE_X;      // a31

endpackage

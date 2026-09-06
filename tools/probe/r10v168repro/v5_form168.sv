// r10v168repro/v5_form168.sv — MEASUREMENT ONLY.  THE AWAY HUNT.
// Every WRITTEN MEMBER FORM the implementer's arm A did not spell, chosen from
// Surelog's own `ExprBuilder::fromVpiValue` switch: UNSIZED based literals of
// every base (the `'d`/`'o`/`'b`/`'h` forms whose `tick` is at offset 0), the
// SIGNED based forms (`'sd`/`'sh`/`'so`/`'sb`), underscore-separated digits,
// upper-case bases, the SCAL: path (a 1-bit x/z member, where fromVpiValue
// returns NULL and Surelog falls back to the auto-numbering counter), a 4-bit
// z member, and the auto member that FOLLOWS each of them.
//
// Cell = the folded constant's vpiConstType at a package parameter.  A single
// AWAY here refutes the law.
package sennet_pkg;

  // ---- UNSIZED based literals (tick at offset 0) ----------------------
  typedef enum bit [7:0]   { AMICE_UD = 'd9,    AMICE_UDN } amice_e;
  typedef enum bit [7:0]   { BEZEL_UO = 'o17,   BEZEL_UON } bezel_e;
  typedef enum logic [7:0] { CIVET_UB = 'b1011, CIVET_UBN } civet_e;
  typedef enum logic [7:0] { DIRAC_UH = 'hB,    DIRAC_UHN } dirac_e;
  parameter amice_e f_ud   = AMICE_UD;   // v501 unsized based DECIMAL
  parameter amice_e f_udn  = AMICE_UDN;  // v502
  parameter bezel_e f_uo   = BEZEL_UO;   // v503 unsized OCTAL
  parameter bezel_e f_uon  = BEZEL_UON;  // v504
  parameter civet_e f_ub   = CIVET_UB;   // v505 unsized BINARY
  parameter civet_e f_ubn  = CIVET_UBN;  // v506
  parameter dirac_e f_uh   = DIRAC_UH;   // v507 unsized HEX
  parameter dirac_e f_uhn  = DIRAC_UHN;  // v508

  // ---- SIGNED based literals ------------------------------------------
  typedef enum bit signed [7:0]   { EYRIE_SD = 8'sd12,   EYRIE_SDN } eyrie_e;
  typedef enum bit signed [7:0]   { FLUKE_SH = 8'sh1F,   FLUKE_SHN } fluke_e;
  typedef enum bit signed [7:0]   { GLEBE_SO = 8'so27,   GLEBE_SON } glebe_e;
  typedef enum logic signed [7:0] { HOYDEN_SB = 8'sb0011_0101, HOYDEN_SBN } hoyden_e;
  parameter eyrie_e  f_sd  = EYRIE_SD;   // v509 signed based DECIMAL
  parameter eyrie_e  f_sdn = EYRIE_SDN;  // v510
  parameter fluke_e  f_sh  = FLUKE_SH;   // v511
  parameter fluke_e  f_shn = FLUKE_SHN;  // v512
  parameter glebe_e  f_so  = GLEBE_SO;   // v513 signed OCTAL
  parameter glebe_e  f_son = GLEBE_SON;  // v514
  parameter hoyden_e f_sb  = HOYDEN_SB;  // v515
  parameter hoyden_e f_sbn = HOYDEN_SBN; // v516

  // ---- UNDERSCORES and UPPER-CASE bases --------------------------------
  typedef enum bit [15:0]   { IXIA_US = 16'd1_2_3,      IXIA_USN } ixia_e;
  typedef enum bit [15:0]   { JORAM_UC = 16'D456,       JORAM_UCN } joram_e;
  typedef enum logic [15:0] { KNURL_HC = 16'HaB_cD,     KNURL_HCN } knurl_e;
  typedef enum logic [15:0] { LOTIC_OC = 16'O1_2_3_4,   LOTIC_OCN } lotic_e;
  typedef enum logic [15:0] { MEROP_BC = 16'B1010_0101_1100_0011, MEROP_BCN } merop_e;
  parameter ixia_e  f_usc  = IXIA_US;    // v517 underscored based decimal
  parameter ixia_e  f_uscn = IXIA_USN;   // v518
  parameter joram_e f_ucd  = JORAM_UC;   // v519 UPPER-CASE 'D
  parameter joram_e f_ucdn = JORAM_UCN;  // v520
  parameter knurl_e f_uch  = KNURL_HC;   // v521 UPPER-CASE 'H, mixed digits
  parameter knurl_e f_uchn = KNURL_HCN;  // v522
  parameter lotic_e f_uco  = LOTIC_OC;   // v523 UPPER-CASE 'O, underscores
  parameter lotic_e f_ucon = LOTIC_OCN;  // v524
  parameter merop_e f_ucb  = MEROP_BC;   // v525 UPPER-CASE 'B
  parameter merop_e f_ucbn = MEROP_BCN;  // v526

  // ---- the SCAL: path — fromVpiValue returns NULL and Surelog falls back
  //      to the auto-numbering counter with Type::Integer -----------------
  typedef enum logic [0:0] { NIXIE_Z = 1'bz } nixie_e;
  typedef enum logic [0:0] { ORPIN_X = 1'bx } orpin_e;
  typedef enum logic [3:0] { PLINTH_MZ = 4'b1z0x } plinth_e;
  parameter nixie_e  f_scz = NIXIE_Z;    // v527
  parameter orpin_e  f_scx = ORPIN_X;    // v528
  parameter plinth_e f_mxz = PLINTH_MZ;  // v529

  // ---- a member initialised from ANOTHER PARAMETER (evalExpr path) -----
  parameter int QUINSY_SRC = 6;
  typedef enum bit [7:0] { RIMU_P = QUINSY_SRC, RIMU_PN } rimu_e;
  parameter rimu_e f_pinit = RIMU_P;     // v530
  parameter rimu_e f_pnext = RIMU_PN;    // v531

  // ---- a member initialised from an EARLIER MEMBER of the same enum ----
  typedef enum bit [7:0] { SIRIH_A = 8'd3, SIRIH_B = SIRIH_A + 8'd1, SIRIH_C } sirih_e;
  parameter sirih_e f_mref  = SIRIH_B;   // v532
  parameter sirih_e f_mrefn = SIRIH_C;   // v533

  // ---- a member initialised from a CAST -------------------------------
  typedef enum bit [7:0] { TERAI_C = 8'(3), TERAI_CN } terai_e;
  parameter terai_e f_cinit = TERAI_C;   // v534
  parameter terai_e f_cnext = TERAI_CN;  // v535

  // ---- a member initialised by a NEGATIVE based literal ----------------
  typedef enum bit signed [7:0] { URIAL_N = -8'sd5, URIAL_NN } urial_e;
  parameter urial_e f_negb  = URIAL_N;   // v536
  parameter urial_e f_negbn = URIAL_NN;  // v537

  // ---- a member initialised by a PARENTHESISED literal ------------------
  typedef enum bit [7:0] { VIRGA_P = (8'd7), VIRGA_PN } virga_e;
  parameter virga_e f_parl  = VIRGA_P;   // v538
  parameter virga_e f_parln = VIRGA_PN;  // v539

endpackage

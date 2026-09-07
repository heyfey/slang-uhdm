// r10v188repro/arms/v188_c_bases.sv — ADVERSARIAL ENUM BASES.
// The law claims the enum's BASE TYPE PLAYS NO PART.  Six identical shapes are
// repeated under ten different bases (none, int, int unsigned, byte, shortint,
// longint, bit[23:0], logic[7:0], a SIGNED vector, a typedef name).  If the
// base does enter the size or the encoding, one of these rows moves AWAY.
package v188c_pkg;
  typedef bit [27:0] v188c_tdef_t;

  typedef enum                 { C0_A = 1 << 4, C0_B = 3 + 5, C0_C = 9 - 2,
                                 C0_D = 2 * 3,  C0_E = 'h4 + 1,
                                 C0_F = 4'h2 + 4'h1 } c0_e;
  typedef enum int             { C1_A = 1 << 4, C1_B = 3 + 5, C1_C = 9 - 2,
                                 C1_D = 2 * 3,  C1_E = 'h4 + 1,
                                 C1_F = 4'h2 + 4'h1 } c1_e;
  typedef enum int unsigned    { C2_A = 1 << 4, C2_B = 3 + 5, C2_C = 9 - 2,
                                 C2_D = 2 * 3,  C2_E = 'h4 + 1,
                                 C2_F = 4'h2 + 4'h1 } c2_e;
  typedef enum byte            { C3_A = 1 << 4, C3_B = 3 + 5, C3_C = 9 - 2,
                                 C3_D = 2 * 3,  C3_E = 'h4 + 1,
                                 C3_F = 4'h2 + 4'h1 } c3_e;
  typedef enum shortint        { C4_A = 1 << 4, C4_B = 3 + 5, C4_C = 9 - 2,
                                 C4_D = 2 * 3,  C4_E = 'h4 + 1,
                                 C4_F = 4'h2 + 4'h1 } c4_e;
  typedef enum longint         { C5_A = 1 << 4, C5_B = 3 + 5, C5_C = 9 - 2,
                                 C5_D = 2 * 3,  C5_E = 'h4 + 1,
                                 C5_F = 4'h2 + 4'h1 } c5_e;
  typedef enum bit [23:0]      { C6_A = 1 << 4, C6_B = 3 + 5, C6_C = 9 - 2,
                                 C6_D = 2 * 3,  C6_E = 'h4 + 1,
                                 C6_F = 4'h2 + 4'h1 } c6_e;
  typedef enum logic [7:0]     { C7_A = 1 << 4, C7_B = 3 + 5, C7_C = 9 - 2,
                                 C7_D = 2 * 3,  C7_E = 'h4 + 1,
                                 C7_F = 4'h2 + 4'h1 } c7_e;
  typedef enum bit signed [15:0] { C8_A = 1 << 4, C8_B = 3 + 5, C8_C = 9 - 2,
                                 C8_D = 2 * 3,  C8_E = 'h4 + 1,
                                 C8_F = 4'h2 + 4'h1 } c8_e;
  typedef enum v188c_tdef_t    { C9_A = 1 << 4, C9_B = 3 + 5, C9_C = 9 - 2,
                                 C9_D = 2 * 3,  C9_E = 'h4 + 1,
                                 C9_F = 4'h2 + 4'h1 } c9_e;
endpackage

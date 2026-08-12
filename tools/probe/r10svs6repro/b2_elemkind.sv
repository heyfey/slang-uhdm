// r10svs6 arm b2 — EVERY ELEMENT KIND of a FIXED-SIZE unpacked-array CLASS
// PROPERTY, with the MODULE-scope twin of each (m-prefix).  This is the arm the
// brief's element-kind grid is read from, and it is also the arm that decides
// whether § arrayVarSignedWritten8 (`vpiSigned` on the array_var iff the element
// is written as a SIGNED integer atom / bit-logic-reg scalar or vector, and the
// declaration is not itself a typedef name) fires the same way at class scope for
// a FIXED array as it does for a dynamic one.
typedef enum bit [1:0] {A0, A1} e_t;
typedef enum byte signed {S0 = -1, S1 = 1} se_t;
typedef struct packed {byte a; byte b;} ps_t;
typedef struct {byte a; string s;} us_t;
typedef byte b_t;
typedef byte barr_t[4];

class Hand;
  int id;
endclass

class b2_cls;
  int c01_int[4];
  int unsigned c02_intu[4];
  byte c03_byte[4];
  byte unsigned c04_byteu[4];
  shortint c05_shint[4];
  longint c06_lgint[4];
  integer c07_integer[4];
  time c08_time[4];
  bit c09_bit[4];
  logic c10_logic[4];
  reg c11_reg[4];
  bit [7:0] c12_bitv[4];
  bit signed [7:0] c13_bitsv[4];
  logic signed [7:0] c14_logsv[4];
  real c15_real[4];
  shortreal c16_sreal[4];
  string c17_string[4];
  e_t c18_enum[4];
  se_t c19_senum[4];
  ps_t c20_pstruct[4];
  us_t c21_ustruct[4];
  Hand c22_hand[4];
  chandle c23_chandle[4];
  b_t c24_btd[4];
  barr_t c25_wholetd;
endclass

module b2_top;
  int m01_int[4];
  int unsigned m02_intu[4];
  byte m03_byte[4];
  byte unsigned m04_byteu[4];
  shortint m05_shint[4];
  longint m06_lgint[4];
  integer m07_integer[4];
  time m08_time[4];
  bit m09_bit[4];
  logic m10_logic[4];
  reg m11_reg[4];
  bit [7:0] m12_bitv[4];
  bit signed [7:0] m13_bitsv[4];
  logic signed [7:0] m14_logsv[4];
  real m15_real[4];
  shortreal m16_sreal[4];
  string m17_string[4];
  e_t m18_enum[4];
  se_t m19_senum[4];
  ps_t m20_pstruct[4];
  us_t m21_ustruct[4];
  Hand m22_hand[4];
  chandle m23_chandle[4];
  b_t m24_btd[4];
  barr_t m25_wholetd;
  b2_cls c;
endmodule

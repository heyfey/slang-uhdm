// r10v95 arm b1 — every $bits ARGUMENT KIND in a module initial block.
// Deliberately varied names/widths/orders so no cell can confirm another.
typedef struct packed { logic [11:0] hi; logic [3:0] lo; } ps16_t;
typedef struct { byte qa; int qb; } us40_t;
typedef union packed { logic [7:0] u8; logic [7:0] v8; } pu8_t;
typedef enum logic [2:0] { E0, E1, E2 } e3_t;
typedef logic [24:0] w25_t;

class Hnd7;
  int junk;
endclass

module b1;
  bit  [31:0] v32;
  bit  [7:0]  pk4 [4];
  logic [15:0] w2 [3];
  int   md [2][3];
  byte  dyn [];
  shortint que [$];
  int   asso [string];
  ps16_t sp1;
  ps16_t spa [2];
  us40_t us1;
  pu8_t  pu1;
  e3_t   en1;
  w25_t  tw1;
  real   rr1;
  shortreal sr1;
  realtime  rt1;
  time      tm1;
  string    st1;
  chandle   ch1;
  Hnd7      hd1;
  logic [3:0][7:0] mp1;
  logic [99:0] big100;
  integer ig1;
  logic [5:0] xz1;
  parameter int PW = 9;
  localparam int LW = 13;
  logic [PW-1:0] pvar;

  int r [40];
  initial begin
    // --- type keywords / typedefs
    r[0]  = $bits(byte);
    r[1]  = $bits(int);
    r[2]  = $bits(ps16_t);
    r[3]  = $bits(us40_t);
    r[4]  = $bits(pu8_t);
    r[5]  = $bits(e3_t);
    r[6]  = $bits(w25_t);
    // --- bare vars
    r[7]  = $bits(v32);
    r[8]  = $bits(pk4);
    r[9]  = $bits(md);
    r[10] = $bits(dyn);
    r[11] = $bits(que);
    r[12] = $bits(asso);
    r[13] = $bits(sp1);
    r[14] = $bits(us1);
    r[15] = $bits(rr1);
    r[16] = $bits(sr1);
    r[17] = $bits(rt1);
    r[18] = $bits(tm1);
    r[19] = $bits(st1);
    r[20] = $bits(hd1);
    r[21] = $bits(mp1);
    r[22] = $bits(big100);
    r[23] = $bits(ig1);
    // --- selects
    r[24] = $bits(v32[3]);
    r[25] = $bits(v32[7:0]);
    r[26] = $bits(pk4[2]);
    r[27] = $bits(pk4[2][5]);
    r[28] = $bits(w2[1][7:0]);
    r[29] = $bits(md[1][2]);
    r[30] = $bits(dyn[1]);
    r[31] = $bits(que[0]);
    r[32] = $bits(asso["k"]);
    r[33] = $bits(mp1[2]);
    r[34] = $bits(big100[70:1]);
    r[35] = $bits(pvar[2]);
    // --- member / member+select / select+member
    r[36] = $bits(sp1.hi);
    r[37] = $bits(spa[1].lo);
    r[38] = $bits(us1.qb);
    r[39] = $bits(en1);
  end
endmodule

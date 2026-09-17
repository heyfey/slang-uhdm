// r11u61 h5 — THE BAIL, with UNAMBIGUOUS literals.  Every member value is an
// unbased decimal, so an operand at 64 is UNSIZED and an operand at the member
// width was SIZED by the walk: the two are never confusable here.
module h5 (input logic clk);
  typedef struct { byte b8; logic [95:0] w96; shortint s16; } bw_t; // >64 member
  typedef struct { byte b8; time t;          shortint s16; } bt_t; // time member
  typedef struct { byte b8; real r;          shortint s16; } br_t; // real member
  typedef struct { byte b8; string s;        shortint s16; } bs_t; // string member
  typedef struct { byte b8; shortint m16;    shortint s16; } bok_t;// the control
  localparam bw_t  BW  = '{b8: 1, w96: 2, s16: 3};
  localparam bt_t  BT  = '{b8: 1, t:   2, s16: 3};
  localparam br_t  BR  = '{b8: 1, r:   2, s16: 3};
  localparam bs_t  BS  = '{b8: 1, s: "z", s16: 3};
  localparam bok_t BOK = '{b8: 1, m16: 2, s16: 3};
  wire z = clk ^ BW.b8[0] ^ BT.b8[0] ^ BR.b8[0] ^ BS.b8[0] ^ BOK.b8[0];
endmodule

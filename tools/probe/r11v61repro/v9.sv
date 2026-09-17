// v11u61 arm v9 — NEGATIVE / SIGNED VALUES, packed control beside the unpacked face
module v9;
  typedef struct packed { byte a; byte b; } p8_t;
  localparam p8_t PN = '{a: -3, b: -4};
  typedef struct { byte a; byte b; } u8_t;
  localparam u8_t UN = '{a: -3, b: -4};
  typedef struct { byte a; byte b; } bl_t;
  localparam bl_t BN = '{a: 8'shFD, b: 8'shFC};
  typedef struct { shortint a; int b; } sw_t;
  localparam sw_t N2 = '{a: -1, b: -1};
  localparam int NK = -5;
  typedef struct { byte a; byte b; } pr_t;
  localparam pr_t N3 = '{a: NK, b: 2};
  typedef struct packed { shortint a; int b; } psw_t;
  localparam psw_t PSW = '{a: -1, b: -1};
endmodule

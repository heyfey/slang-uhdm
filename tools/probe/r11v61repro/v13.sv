// v11u61 arm v13 — the OTHER get_uvalue bails: x/z digits and an over-64-bit operand
module v13;
  typedef struct { logic [7:0] a; shortint b; } xz_t;
  localparam xz_t X1 = '{a: 4'b1x01, b: 2};
  localparam xz_t X2 = '{a: 3, b: 4'b1z10};
  typedef struct { int a; shortint b; } wd_t;
  localparam wd_t S1 = '{a: 65'd5, b: 2};
  typedef struct { logic [7:0] a; shortint b; } sc_t;
  localparam sc_t Z1 = '{a: 1'bx, b: 2};
endmodule

// v11u61 arm v2 — WIDTHS, SIGNEDNESS, 4-STATE VALUES
module v2;
  typedef struct { bit b1; logic [6:0] l7; longint l64; } w_t;
  localparam w_t W1 = '{b1: 1, l7: 7'h5a, l64: 64'hdeadbeef00000001};
  typedef struct { byte s8; int s32; } sg_t;
  localparam sg_t G1 = '{s8: -3, s32: -70000};
  typedef struct { logic [3:0] a; logic [3:0] b; } x_t;
  localparam x_t X1 = '{a: 4'b1x01, b: 4'b1z10};
  typedef struct { logic [64:0] big; byte b; } bg_t;
  localparam bg_t B1 = '{big: 65'd5, b: 2};
  typedef struct { logic [63:0] sixtyfour; byte b; } ok_t;
  localparam ok_t K1 = '{sixtyfour: 64'd5, b: 2};
endmodule

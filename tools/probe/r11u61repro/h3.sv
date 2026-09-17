// r11u61 h3 — THE UNPACKED STRUCT is the face h2's packed twin already gets
// right.  Member widths 8 / 16 / 32 / 64 so "the MEMBER width" is separable
// from 32 and from 64; element kinds swept per parameter.
package p3;
  typedef enum logic [5:0] { F0 = 6'd9, F1 = 6'd10 } e3_t;
endpackage
module h3 import p3::*; (input logic clk);
  typedef struct { byte b8; shortint s16; int i32; longint l64; } u3_t;
  localparam u3_t UPLAIN = '{b8: 1, s16: 2, i32: 3, l64: 4};
  localparam u3_t UBASED = '{b8: 2'b11, s16: 8'hAB, i32: 4'd5, l64: 3'b101};
  localparam u3_t UENUM  = '{b8: 1, s16: F0, i32: 2, l64: F1};
  localparam u3_t UCAT   = '{b8: 1, s16: {4'b1010, 4'b0101}, i32: 2, l64: 3};
  localparam u3_t UREP   = '{b8: 1, s16: 2, i32: {3{1'b1}}, l64: 4};
  localparam u3_t UDEF   = '{b8: 1, default: 0};
  localparam u3_t UPOS   = '{1, 2, 3, 4};
  wire x = clk ^ UPLAIN.b8[0] ^ UBASED.b8[0] ^ UENUM.b8[0] ^ UCAT.b8[0]
                ^ UREP.b8[0] ^ UDEF.b8[0] ^ UPOS.b8[0];
endmodule
